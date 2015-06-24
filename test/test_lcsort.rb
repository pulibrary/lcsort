require 'minitest/autorun'
require 'lcsort'

class LcsortTest < Minitest::Test

  def test_normalization
    # pairs, left hand normalizes to right-hand
    [ 
      ['A1',      'A  0001'],
      ['B22.3',   'B  0022300000'],
      ['C1.D11',  'C  0001000000D110'],
      ['d15.4 .D22 1990', 'D  0015400000D220 000 000 1990'],  
      ['E8 C11 D22',      'E  0008000000C110D220'],
      ['ZA4082G33M434.D54 1998', 'ZA 4082000000G330M434D540 1998']
    ].each do |call, normalized|
      assert_normalizes_as call, normalized
    end
  end

  def test_endrange
    # pairs of call number, and expected bottomout/endrange normalized
    [
      ['A1',     'A  0001999999~999~999~999'],
      ['B22.3',  'B  0022399999~999~999~999'],
      ['C1.D11', 'C  0001000000D119~999~999'],
      ['d15.4 .D22 1990', 'D  0015400000D220 000 000 1990'],
      ['E8 C11 D22',      'E  0008000000C110D229~999'], 
      ['ZA4082G33M434.D54 1998', 'ZA 4082000000G330M434D540 1998']
    ].each do |call, normalized|
      assert_normalizes_bottomout_as call, normalized
    end      
  end

  def test_non_recognized
    assert_nil Lcsort.normalize("microform")
    assert_nil Lcsort.normalize("this is not a call number")
    assert_nil Lcsort.normalize("12234")
    assert_nil Lcsort.normalize("928.12")
  end

  def test_variants
    # variants that should all normalize the same
    [
      ['B 22.3', 'B22.3'],
      ['C1.D11', 'C 1.D11', 'C 1.D11', 'C 1 .D11'],
      ['D15.4 .D22 1990', 'D 15.4 .D22 1990', 'D15.4.D22 1990', 'D15.4.D22 1990'],
      ['E8 C11 D22', 'E8 .C11 .D22', 'E8 .C11.D22', 'E8 .C11D22', 'E8C11D22']
    ].each do |list|
      assert_variants_normalize_same(list)
    end
  end


  def test_parses_weird_numbers
    # These may NOT be currently sorted correctly, but they parse somehow,
    # and we want to at least keep it that way, I think.     
    refute_nil Lcsort.normalize("A1.2 .A54 21st 2010")
    refute_nil Lcsort.normalize("KF 4558 15th .G8")
    refute_nil Lcsort.normalize("JX 45.5 2nd .A54 .G888 2010")
  end

  def assert_normalizes_as(callno, expected)
    actual = Lcsort.normalize(callno)
    assert_equal expected, actual, "Expected `#{callno}` to normalize as `#{expected}` not `#{actual}`"
  end

  def assert_normalizes_bottomout_as(callno, expected)
    actual = Lcsort.normalize(callno, :bottomout => true)
    assert_equal expected, actual, "Expected `#{callno}` to end range normalize as `#{expected}` not `#{actual}`"
  end

  def assert_variants_normalize_same(list)
    first_call = list.shift

    list.each do |call|
      assert_equal Lcsort.normalize(first_call), Lcsort.normalize(call), "Expected `#{call}` to normalize identical to `#{first_call}`"
      assert_equal Lcsort.normalize(first_call, :bottomout => true), Lcsort.normalize(call, :bottomout => true), "Expected `#{call}` to bottomout/endrange normalize identical to `#{first_call}`"
    end
  end

end