require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def valid_params
    {
      user: {
        name: "Chidi Obi",
        email_address: "chidi@example.com",
        phone: "0803 555 0000",
        password: "secret-pass",
        password_confirmation: "secret-pass"
      }
    }
  end

  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create signs the owner up and logs them in" do
    assert_difference -> { User.count } => 1, -> { Session.count } => 1 do
      post registration_path, params: valid_params
    end

    assert_redirected_to root_path
    assert cookies[:session_id].present?
    assert_equal "+2348035550000", User.find_by(email_address: "chidi@example.com").phone
  end

  test "create with invalid data re-renders the form with errors" do
    params = valid_params.deep_merge(user: { password_confirmation: "different" })

    assert_no_difference -> { User.count } do
      post registration_path, params: params
    end

    assert_response :unprocessable_entity
    assert_select "#form_errors"
  end

  test "create ignores attributes that aren't permitted" do
    params = valid_params.deep_merge(user: { password_digest: "injected" })
    post registration_path, params: params

    user = User.find_by(email_address: "chidi@example.com")
    assert user.authenticate("secret-pass"), "password_digest must come from the password, not the request"
  end

  test "create without a user param returns bad request" do
    post registration_path, params: { name: "no wrapper" }
    assert_response :bad_request
  end

  test "a logged-in owner is redirected away from sign-up" do
    sign_in_as users(:one)
    get new_registration_path
    assert_redirected_to root_path
  end
end
