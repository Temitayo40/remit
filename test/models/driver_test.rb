require "test_helper"

class DriverTest < ActiveSupport::TestCase
  def build_driver(**overrides)
    users(:one).drivers.new({ name: "Ifeanyi Eze", phone: "0802 000 1234" }.merge(overrides))
  end

  test "name and phone are enough" do
    assert build_driver.valid?
  end

  test "new drivers are active with reminders on" do
    driver = build_driver
    assert driver.active?
    assert driver.reminders_enabled?
  end

  test "driver and guarantor phones are normalized" do
    driver = build_driver(guarantor_phone: "0809 111 2222")
    assert_equal "+2348020001234", driver.phone
    assert_equal "+2348091112222", driver.guarantor_phone
  end

  test "blank optional fields are stored as nil" do
    driver = build_driver(guarantor_name: "  ", guarantor_phone: "", notes: "  ")
    assert_nil driver.guarantor_name
    assert_nil driver.guarantor_phone
    assert_nil driver.notes
  end

  test "requires a valid phone" do
    driver = build_driver(phone: "12345")
    assert_not driver.valid?
    assert driver.errors[:phone].any?
  end

  test "an invalid guarantor phone is rejected" do
    assert_not build_driver(guarantor_phone: "999").valid?
  end

  test "the same owner can't add a driver's number twice" do
    driver = build_driver(phone: "0806 111 2222") # drivers(:emeka)
    assert_not driver.valid?
    assert_includes driver.errors[:phone], "already belongs to one of your drivers"
  end

  test "another owner can add the same driver" do
    driver = users(:two).drivers.new(name: "Emeka Nwosu", phone: "08061112222")
    assert driver.valid?
  end
end
