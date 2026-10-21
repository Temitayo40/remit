require "test_helper"

class PhoneNumberTest < ActiveSupport::TestCase
  test "normalizes the common ways Nigerian numbers are written" do
    [
      "08031234567",
      "0803 123 4567",
      "0803-123-4567",
      "8031234567",
      "2348031234567",
      "+2348031234567",
      "+234 803 123 4567",
      "+234 (0)803 123 4567",
      " 0803.123.4567 "
    ].each do |input|
      assert_equal "+2348031234567", PhoneNumber.normalize(input), "for input #{input.inspect}"
    end
  end

  test "returns nil for blank input" do
    assert_nil PhoneNumber.normalize("")
    assert_nil PhoneNumber.normalize(nil)
  end

  test "leaves unrecognisable input as typed so validation can reject it" do
    assert_equal "12345", PhoneNumber.normalize(" 12345 ")
    assert_equal "+447911123456", PhoneNumber.normalize("+447911123456")
  end

  test "valid? accepts only +234 mobile numbers" do
    assert PhoneNumber.valid?("+2347031234567")
    assert PhoneNumber.valid?("+2348031234567")
    assert PhoneNumber.valid?("+2349131234567")

    assert_not PhoneNumber.valid?("+2341031234567"), "must start with 7, 8 or 9"
    assert_not PhoneNumber.valid?("+234803123456"), "too short"
    assert_not PhoneNumber.valid?("08031234567"), "not normalized"
    assert_not PhoneNumber.valid?(nil)
  end
end
