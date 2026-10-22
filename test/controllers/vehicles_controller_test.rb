require "test_helper"

class VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @vehicle = vehicles(:keke)
  end

  test "index lists my vehicles, in service and out of service" do
    get vehicles_path

    assert_response :success
    assert_select "#vehicles", /LND123AB/
    assert_select "#vehicles", /KJA456CD/
    assert_select "#inactive_vehicles", /EKY789EF/
  end

  test "new" do
    get new_vehicle_path
    assert_response :success
  end

  test "create adds a vehicle to my account" do
    assert_difference -> { users(:one).vehicles.count } => 1 do
      post vehicles_path, params: { vehicle: {
        plate_number: "ojo 222 kl", vehicle_type: "okada", rate_naira: "3,500",
        rate_frequency: "daily", rest_days: [ "", "0" ]
      } }
    end

    vehicle = Vehicle.order(:created_at).last
    assert_redirected_to vehicle_path(vehicle)
    assert_equal "OJO222KL", vehicle.plate_number
    assert_equal 350_000, vehicle.rate_kobo
    assert_equal [ 0 ], vehicle.rest_days
  end

  test "create with bad input re-renders the form" do
    assert_no_difference -> { Vehicle.count } do
      post vehicles_path, params: { vehicle: { plate_number: "", vehicle_type: "keke", rate_naira: "abc" } }
    end

    assert_response :unprocessable_entity
    assert_select "#form_errors", /Amount due/
  end

  test "show" do
    get vehicle_path(@vehicle)
    assert_response :success
    assert_select "h1", "LND123AB"
    assert_select "dd", /₦5,000/
  end

  test "edit" do
    get edit_vehicle_path(@vehicle)
    assert_response :success
    assert_select "input[name='vehicle[rate_naira]'][value='5000']"
  end

  test "update changes the rate and rest days" do
    patch vehicle_path(@vehicle), params: { vehicle: { rate_naira: "6000", rest_days: [ "" ] } }

    assert_redirected_to vehicle_path(@vehicle)
    @vehicle.reload
    assert_equal 600_000, @vehicle.rate_kobo
    assert_equal [], @vehicle.rest_days
  end

  test "update can take a vehicle out of service" do
    patch vehicle_path(@vehicle), params: { vehicle: { active: "0" } }
    assert_not @vehicle.reload.active?
  end

  test "there is no delete route" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/vehicles/#{@vehicle.id}", method: :delete)
    end
  end

  test "visitors must log in" do
    sign_out
    get vehicles_path
    assert_redirected_to new_session_path
  end

  # --- Owner isolation: the most important tests in the app (README §6) ---

  test "index never shows another owner's vehicles" do
    get vehicles_path
    assert_no_match "ABJ111GH", response.body
  end

  test "another owner's vehicle can't be viewed, edited or updated" do
    other = vehicles(:other_owners_keke)

    get vehicle_path(other)
    assert_response :not_found

    get edit_vehicle_path(other)
    assert_response :not_found

    patch vehicle_path(other), params: { vehicle: { rate_naira: "1" } }
    assert_response :not_found
    assert_equal 450_000, other.reload.rate_kobo
  end

  test "a vehicle can't be created for another owner by sending user_id" do
    post vehicles_path, params: { vehicle: {
      user_id: users(:two).id, plate_number: "XYZ999", vehicle_type: "keke", rate_naira: "5000", rate_frequency: "daily"
    } }

    assert_equal users(:one), Vehicle.find_by!(plate_number: "XYZ999").user
  end
end
