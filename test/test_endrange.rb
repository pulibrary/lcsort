require 'minitest/autorun'
require 'lcsort'

# Tests for what's current `:bottomout => true` DOING what it's meant to,
# without worrying about implementation. Argument name may change. 
class TestEndRange < Minitest::Test

  # We're testing to make sure the endrange is higher than the original, lower
  # then the 'next step', and higher than some intermediate forms
  def test_bottomouts
    # We're not sure about this behavior for class-letter only, should
    # it really allow "ABA" as inside "AB"? But original code did, so we stick
    # with it. 
    assert_bottomout_ranges("AB", 
      :higher => ["AC", "AC 1", "B", "B 1"], 
      :inside => [
        "ABA",
        "ABA 101",
        "ABZ",
        "ABZ 101",
        "ABZ 101 other stuff",
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

    assert_bottomout_ranges("AB 101", 
      :higher => ["AC 1", "ABA 1", "B 1"], 
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

    assert_bottomout_ranges("E8 C21 D22",
      :higher => ["E8 C22 D22", "E8 C3", "E8 C21 D23"],
      :inside => [
        "E8 C21 D2213",
        "E8 C21 D2299",
        "E8 C21 D2299 A13",
        "E8 C21 D2299 1990",
    ])

  end

  def test_decimal_truncation
    # bottomout of AB 10.1 includes AB 10.123 for instance -- truncation
    # on decimals. Not sure why this makes sense, but it's what original
    # Dueber code did, so we keep it. 

    assert_bottomout_ranges("AB 101.4",
      :higher => ["AB 101.5", "AB 102", "AC 1"],
      :inside => [
        "AB 101.41",
        "AB 101.41 .A1 .B1",
        "AB 101.4345",
        "AB 101.4345 .G1"
    ])

  end

  def test_extra_in_input
    # If 'extra' component is input, bottomout is effecitively ignored,
    # you get standard sort key back. Not exactly sure of the use case,
    # but that's what original Dueber code did so we'll stick with it. 
    [
      "AB extra extra",
      "AB 10 extra extra",
      "AB 10.1 extra extra",
      "AB 10.1 .A100 extra extra",
      "AB 10.1 .A100 .B100 extra extra"
    ].each do |callno|
      assert_equal Lcsort.normalize(callno), Lcsort.normalize(callno, :bottomout => true), "Expect bottomout of input with 'extra' component to be the standard normalized form"
    end
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