require 'minitest/autorun'
require 'lcsort'

# Tests for what's current `:bottomout => true` DOING what it's meant to,
# without worrying about implementation. Argument name may change. 
class TestEndRange < Minitest::Test

  # We're testing to make sure the endrange is higher than the original, lower
  # then the 'next step', and higher than some intermediate forms
  def test_bottomouts
    assert_bottomout_ranges("AB 101", 
      :higher => ["AC 1"], 
      :inside => [
        "AB 101 1900",
        "AB 101 other stuff",
        "AB 101.4",
        "AB 101.400",
        "AB 101 .A100",
        "AB 101.400 .A100",
        "AB 101.400 .A100 1900",
        "AB 101.400 .A100 .B300",
        "AB 101.400 .A100 .B300 .C300",
        "AB 101.400 .A100 .B300 .C300 1900 other stuff"
    ])

    assert_bottomout_ranges("AB 101.4", 
      :higher => ["AB 101.5", "AB 102"], 
      :inside => [
        "AB 101.4 1900",
        "AB 101.4 1900 other stuff",
        "AB 101.400",
        "AB 101 .A100",
        "AB 101.400 .A100",
        "AB 101.400 .A100 1900",
        "AB 101.400 .A100 .B300",
        "AB 101.400 .A100 .B300 .C300",
        "AB 101.400 .A100 .B300 .C300 1900 other stuff"
    ])

    assert_bottomout_ranges("AB 101.4 .A111", 
      :higher => ["AB 101.4 .B100", "AB 101.4 .A2", "AB 101.4 .A2 extra"], 
      :inside => [
        "AB 101.4 .A11124",
        "AB 101.4 .A11124 1900",
        "AB 101.4 .A11124 other stuff",
        "AB 101.4 .A111 1900",
        "AB 101.4 .A111 other stuff",
        "AB 101.400 .A111 .B300",
        "AB 101.400 .A111 .B300 .C300",
        "AB 101.400 .A111 .B300 .C300 1900 other stuff"
    ])

    assert_bottomout_ranges("AB 101.4 .A100 .B2", 
      :higher => ["AB 101.4 .B3", "AB 101.4 .C1"], 
      :inside => [
        "AB 101.4 .A100 .B2 extra",
        "AB 101.4 .A100 .B211",
        "AB 101.4 .A100 .B211 .C3",
        "AB 101.4 .A100 .B211 extra",
        "AB 101.4 .A100 .B211 .C3 extra",
        "AB 101.4 .A100 .B211 .C3 1900",
        "AB 101.4 .A100 .B2 1900 extra"
    ])
  end

  def assert_bottomout_ranges(original, args)
    inside = args[:inside] or raise ArgumentError, "Require :inside list"
    higher = args[:higher] or raise ArgumentError, "Require :higher list"

    normalized = Lcsort.normalize(original)
    normalized_end = Lcsort.normalize(original, :bottomout => true)

    assert normalized < normalized_end, "Expected bottomout to be higher than straight normalized `#{original}`"

    higher.each do |call|
      assert normalized_end < Lcsort.normalize(call), "expected bottomout(#{original}) to be less than #{call}"
    end

    inside.each do |call|
      assert Lcsort.normalize(call) <  normalized_end, "expected bottomout(#{original}) to be greater than #{call}"
    end

  end

  

end