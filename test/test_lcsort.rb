require 'minitest/autorun'
require 'lcsort'

# We have a few tests for expected normalized output, just for
# sanity check. But mainly the semantic tests in test_lcsort
# and test_endrange ensure expected behavior from our sort keys.
#
# But if changes to code require changes to these tests, it probably
# means sortkeys are no longer compatible with prior version, even
# if semantics are maintained.
class LcsortTest < Minitest::Test



  def test_normalization
    # pairs, left hand normalizes to right-hand
    [ 
      ['A1',      'A  0001'],
      ['B22.3',   'B  00223'],
      ['C1.D11',  'C  0001.D11'],
      ['d15.4 .D22 1990', 'D  00154.D22  1990'],  
      ['d15.123456 .D22 1990', 'D  0015123456.D22  1990'],
      ['E8 C11 D22',      'E  0008.C11.D22'],
      ['ZA4082G33M434.D54 1998', 'ZA 4082.G33.M434.D54  1998']
    ].each do |call, normalized|
      assert_normalizes_as call, normalized
    end
  end

  def test_cutter_suffixes
    # pairs, left hand normalizes to right-hand
    [ 
      ['A1 .A1a',      'A  0001.A1-A'],
      ['A1 .A1 .B32a', 'A  0001.A1.B32-A'],
      ['A1 .A1a .B32a .C33 extra', 'A  0001.A1-A.B32-A.C33  EXTRA'],
      ['A1 .A3 .B4 .C33ab extra',  'A  0001.A3.B4.C33-AB  EXTRA']
    ].each do |call, normalized|
      assert_normalizes_as call, normalized
    end
  end

  def test_endrange
    # pairs of call number, and expected bottomout/endrange normalized
    [
      ['A1',     'A  0001~'],
      ['B22.3',  'B  00223~'],
      ['C1.D11', 'C  0001.D11~'],
      ['d15.4 .D22 1990', 'D  00154.D22  1990'],
      ['E8 C11 D22',      'E  0008.C11.D22~'], 
      ['ZA4082G33M434.D54 1998', 'ZA 4082.G33.M434.D54  1998']
    ].each do |call, normalized|
      assert_normalizes_bottomout_as call, normalized
    end      
  end

  def test_non_recognized
    assert_nil Lcsort.normalize("microform")
    assert_nil Lcsort.normalize("this is not a call number")
    assert_nil Lcsort.normalize("12234")
    assert_nil Lcsort.normalize("928.12")
    # Too long a class number, we only have space for four digits
    assert_nil Lcsort.normalize("AB 12345")
    assert_nil Lcsort.normalize("AB 12345.22")

    # A class number plus extra ain't enough to be
    # a good call number.
    assert_nil Lcsort.normalize("AB this is not a call number")
    # too long a decimal
    #assert_nil Lcsort.normalize("AB 10.111111111111")
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