require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  def build_vehicle(**overrides)
    users(:one).vehicles.new({
      plate_number: "abc 123 xy",
      vehicle_type: "keke",
      rate_naira: "5,000",
      rate_frequency: "daily"
    }.merge(overrides))
  end

  test "a complete vehicle is valid" do
    assert build_vehicle.valid?
  end

  test "plate number is stored upper-case without spaces or dashes" do
    assert_equal "ABC123XY", build_vehicle(plate_number: " abc-123 xy ").plate_number
  end

  test "rate_naira sets rate_kobo" do
    vehicle = build_vehicle(rate_naira: "₦7,500.50")
    assert_equal 750_050, vehicle.rate_kobo
  end

  test "rate_naira reads back from the stored kobo" do
    assert_equal "5000", vehicles(:keke).rate_naira
  end

  test "an unreadable amount is invalid and keeps what was typed" do
    vehicle = build_vehicle(rate_naira: "five thousand")
    assert_not vehicle.valid?
    assert_equal [ "must be an amount above ₦0, like 5,000" ], vehicle.errors[:rate_kobo]
    assert_equal "five thousand", vehicle.rate_naira
  end

  test "a zero amount is invalid" do
    assert_not build_vehicle(rate_naira: "0").valid?
  end

  test "an unknown vehicle type is a validation error, not a crash" do
    vehicle = build_vehicle(vehicle_type: "tractor")
    assert_not vehicle.valid?
    assert vehicle.errors[:vehicle_type].any?
  end

  test "rest days from checkboxes are cleaned up" do
    vehicle = build_vehicle(rest_days: [ "", "6", "0", "6" ])
    assert_equal [ 0, 6 ], vehicle.rest_days
    assert_equal "Sat, Sun", vehicle.rest_day_names
  end

  test "rest days can't cover the whole week" do
    vehicle = build_vehicle(rest_days: (0..6).to_a)
    assert_not vehicle.valid?
    assert vehicle.errors[:rest_days].any?
  end

  test "weekly vehicles have no rest days" do
    vehicle = build_vehicle(rate_frequency: "weekly", rest_days: [ 0 ])
    vehicle.validate
    assert_equal [], vehicle.rest_days
  end

  test "a plate can't be added twice by the same owner" do
    vehicle = build_vehicle(plate_number: "lnd 123 ab") # vehicles(:keke) is LND123AB
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:plate_number], "is already one of your vehicles"
  end

  test "another owner may have the same plate" do
    vehicle = users(:two).vehicles.new(plate_number: "LND123AB", vehicle_type: "keke", rate_naira: "5000")
    assert vehicle.valid?
  end

  test "the database rejects a non-positive rate even if validations are skipped" do
    vehicle = vehicles(:keke)
    assert_raises(ActiveRecord::StatementInvalid) { vehicle.update_columns(rate_kobo: 0) }
  end

  test "display_name prefers the nickname" do
    assert_equal "Blue keke (LND123AB)", vehicles(:keke).display_name
    assert_equal "KJA456CD", vehicles(:bus).display_name
  end
end
