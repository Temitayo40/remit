require "test_helper"

class DriversControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @driver = drivers(:emeka)
  end

  test "index lists my active and former drivers" do
    get drivers_path

    assert_response :success
    assert_select "#drivers", /Emeka Nwosu/
    assert_select "#drivers", /0806 111 2222/
    assert_select "#inactive_drivers", /Tunde Former/
  end

  test "create adds a driver to my account" do
    assert_difference -> { users(:one).drivers.count } => 1 do
      post drivers_path, params: { driver: { name: "Kunle Ade", phone: "0705 123 4567", reminders_enabled: "1" } }
    end

    driver = Driver.order(:created_at).last
    assert_redirected_to driver_path(driver)
    assert_equal "+2347051234567", driver.phone
  end

  test "create with a duplicate phone re-renders the form" do
    assert_no_difference -> { Driver.count } do
      post drivers_path, params: { driver: { name: "Copy", phone: "08061112222" } }
    end

    assert_response :unprocessable_entity
    assert_select "#form_errors", /already belongs/
  end

  test "show has one-tap WhatsApp and call buttons" do
    get driver_path(@driver)

    assert_response :success
    assert_select "a[href='https://wa.me/2348061112222']"
    assert_select "a[href='tel:+2348061112222']"
    assert_select "a[href='tel:+2348063334444']" # guarantor
  end

  test "edit shows the phone in local format" do
    get edit_driver_path(@driver)
    assert_select "input[name='driver[phone]'][value='0806 111 2222']"
  end

  test "update can turn reminders off" do
    patch driver_path(@driver), params: { driver: { reminders_enabled: "0" } }

    assert_redirected_to driver_path(@driver)
    assert_not @driver.reload.reminders_enabled?
  end

  # --- Owner isolation ---

  test "index never shows another owner's drivers" do
    get drivers_path
    assert_no_match "Sola Other", response.body
  end

  test "another owner's driver can't be viewed, edited or updated" do
    other = drivers(:other_owners_driver)

    get driver_path(other)
    assert_response :not_found

    get edit_driver_path(other)
    assert_response :not_found

    patch driver_path(other), params: { driver: { name: "Hacked" } }
    assert_response :not_found
    assert_equal "Sola Other", other.reload.name
  end

  test "a driver can't be created for another owner by sending user_id" do
    post drivers_path, params: { driver: { user_id: users(:two).id, name: "Sneaky", phone: "08051112222" } }
    assert_equal users(:one), Driver.find_by!(name: "Sneaky").user
  end
end
