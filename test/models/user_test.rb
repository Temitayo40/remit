require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user(**overrides)
    User.new({
      name: "Chidi Obi",
      email_address: "chidi@example.com",
      phone: "0803 555 0000",
      password: "secret-pass",
      password_confirmation: "secret-pass"
    }.merge(overrides))
  end

  test "a complete user is valid" do
    assert valid_user.valid?
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "squishes extra whitespace in name" do
    assert_equal "Chidi Obi", valid_user(name: "  Chidi   Obi ").name
  end

  test "normalizes phone to +234 format" do
    assert_equal "+2348035550000", valid_user.phone
  end

  test "requires a name" do
    user = valid_user(name: " ")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires a Nigerian mobile number" do
    user = valid_user(phone: "12345")
    assert_not user.valid?
    assert user.errors[:phone].any?
  end

  test "rejects a malformed email" do
    assert_not valid_user(email_address: "not-an-email").valid?
  end

  test "email must be unique regardless of case" do
    user = valid_user(email_address: users(:one).email_address.upcase)
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "phone must be unique, even when typed in another format" do
    user = valid_user(phone: "0803 123 4567") # users(:one) is +2348031234567
    assert_not user.valid?
    assert user.errors[:phone].any? { |message| message.include?("already registered") }
  end

  test "password must be at least 8 characters" do
    user = valid_user(password: "short", password_confirmation: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "other fields can be updated without re-entering the password" do
    user = users(:one)
    assert user.update(name: "Ada O.")
  end
end
