require 'minitest_helper'

# Test :append_suffix mainly to make sure it still sorts before EVERYTHING
# after the call number it's appended to. 
class TestAppendSuffix < Minitest::Test
  def test_append_suffix
    # suffix that will sort too late if not done right
    suffix = "~ZZ suffix"

    # Make sure it's doing something
    refute_equal Lcsort.normalize("AB 101"), Lcsort.normalize("AB 101", :append_suffix => suffix)
    assert Lcsort.normalize("AB 101", :append_suffix => suffix).end_with?(suffix)

    assert_append_sorts_after(
      ["AB 101", :append_suffix => suffix],
      [
        "AB 101 aextra extra",
        "AB 101 .A234",
        "AB 101 .A234 aaextra extra",
        "AB 102"
      ]
    )

    assert_append_sorts_after(
      ["AB 101 already existing extra", :append_suffix => suffix],
      [
        "AB 101 bb-next extra",
        "AB 101 .B1",
        "AB 101 .B1 aextra extra",
        "AB 102"
      ]
    )

    assert_append_sorts_after(
      ["AB 101 .A123", :append_suffix => suffix],
      [
        "AB 101 .A123 aextra extra",
        "AB 101 .B1",
        "AB 101 .B1 aextra extra",
        "AB 102"
      ]
    )

    assert_append_sorts_after(
      ["AB 101 .A123 already existing extra", :append_suffix => suffix],
      [ 
        "AB 101 .A123 bb-next extra"
      ]
    )


  end

  def assert_append_sorts_after(args, list_of_later)
    with_appended_suffix = Lcsort.normalize(*args)
    list_of_later.each do |callnum|
      n = Lcsort.normalize(callnum)
      assert n > with_appended_suffix, "Expected normalized #{callnum}(#{n}) to sort after #{args}(#{with_appended_suffix})"
    end 
  end


end