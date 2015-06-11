require 'minitest/autorun'
require 'lcsort'

class LcsortTest < Minitest::Test
  
  TEST_CALLNOS = ['A1', 
    'B22.3',
    'C1.D11',
    'd15.4 .D22 1990',
    'E8 C11 D22',
    'ZA4082G33M434.D54 1998',
    'microfilm'
  ]

  EXPECTED_NORM = ['A  0001',
    'B  0022300000',
    'C  0001000000D110',
    'D  0015400000D220 000 000 1990',
    'E  0008000000C110D220',
    'ZA 4082000000G330M434D540 1998',
    nil
  ]

  EXPECTED_ENDRANGE = ['A  0001999999~999~999~999',
    'B  0022399999~999~999~999',
    'C  0001000000D119~999~999',
    'D  0015400000D220 000 000 1990',
    'E  0008000000C110D229~999',
    'ZA 4082000000G330M434D540 1998',
    nil
  ]

  EXPECTED_WELLFORM = ['A  0001',
    'B  0022300000',
    'C  0001000000D110',
    'D  0015400000D220 000 000 1990',
    'E  0008000000C110D220',
    'ZA 4082000000G330M434D540 1998',
    nil
  ]

  def test_normalization
    TEST_CALLNOS.each_with_index do |callno, i|
      assert_equal EXPECTED_NORM[i], Lcsort.normalize(callno)
    end
  end

  def test_endrange
    TEST_CALLNOS.each_with_index do |callno, i|
      assert_equal EXPECTED_ENDRANGE[i], Lcsort.normalize(callno, :bottomout => true)
    end
  end

  def test_wellform
    TEST_CALLNOS.each_with_index do |callno, i|
      assert_equal EXPECTED_WELLFORM[i], Lcsort.normalize(callno)
    end
  end

  def test_bad_callnums
    assert_nil Lcsort.normalize("this is not a call number")
    assert_nil Lcsort.normalize("12234")
  end

  def test_parses_weird_numbers
    # These may NOT be currently sorted correctly, but they parse somehow,
    # and we want to at least keep it that way, I think.     
    refute_nil Lcsort.normalize("A1.2 .A54 21st 2010")
    refute_nil Lcsort.normalize("KF 4558 15th .G8")
    refute_nil Lcsort.normalize("JX 45.5 2nd .A54 .G888 2010")
  end

end