require "test_helper"

class NairaTest < ActiveSupport::TestCase
  test "to_kobo understands how people type amounts" do
    assert_equal 500_000, Naira.to_kobo("5000")
    assert_equal 500_000, Naira.to_kobo("5,000")
    assert_equal 500_000, Naira.to_kobo("₦5,000")
    assert_equal 500_000, Naira.to_kobo(" 5 000 ")
    assert_equal 250_050, Naira.to_kobo("2500.50")
    assert_equal 250_050, Naira.to_kobo("2,500.5")
    assert_equal 500_000, Naira.to_kobo(5000)
  end

  test "to_kobo is exact (no floating point drift)" do
    assert_equal 1_999, Naira.to_kobo("19.99")
    assert_equal 30, Naira.to_kobo("0.30")
  end

  test "to_kobo returns nil for anything that isn't an amount" do
    [ nil, "", "abc", "5k", "-500", "5.555", "1.2.3" ].each do |input|
      assert_nil Naira.to_kobo(input), "for #{input.inspect}"
    end
  end

  test "format shows kobo only when there are any" do
    assert_equal "₦5,000", Naira.format(500_000)
    assert_equal "₦2,500.50", Naira.format(250_050)
    assert_equal "₦0", Naira.format(0)
    assert_equal "-₦1,500", Naira.format(-150_000) # credit, used for balances later
    assert_equal "", Naira.format(nil)
  end

  test "to_input gives a plain number for form fields" do
    assert_equal "5000", Naira.to_input(500_000)
    assert_equal "2500.05", Naira.to_input(250_005)
    assert_nil Naira.to_input(nil)
  end
end
