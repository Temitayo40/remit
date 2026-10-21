require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) } # phone +2348031234567

  test "new shows the phone field by default" do
    get new_session_path
    assert_response :success
    assert_select "input[type=tel][name=phone]"
    assert_select "input[name=email_address]", count: 0
  end

  test "new shows the email field when asked" do
    get new_session_path(with: "email")
    assert_select "input[type=email][name=email_address]"
    assert_select "input[name=phone]", count: 0
  end

  test "logs in with phone, whatever format the owner types" do
    [ "08031234567", "0803 123 4567", "+234 803 123 4567" ].each do |phone|
      post session_path, params: { with: "phone", phone: phone, password: "password" }

      assert_redirected_to root_path, "for #{phone.inspect}"
      assert cookies[:session_id].present?
      delete session_path
    end
  end

  test "logs in with email" do
    post session_path, params: { with: "email", email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "phone is used when the with param is missing or unexpected" do
    post session_path, params: { with: "admin", phone: "08031234567", password: "password" }
    assert_redirected_to root_path
  end

  test "wrong password with phone goes back to the phone form" do
    post session_path, params: { with: "phone", phone: "08031234567", password: "wrong" }

    assert_redirected_to new_session_path(with: "phone")
    assert_nil cookies[:session_id]
    follow_redirect!
    assert_select "#alert", /phone number or password/
  end

  test "wrong password with email goes back to the email form" do
    post session_path, params: { with: "email", email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path(with: "email")
    assert_nil cookies[:session_id]
  end

  test "missing password fails cleanly instead of erroring" do
    post session_path, params: { with: "phone", phone: "08031234567" }
    assert_redirected_to new_session_path(with: "phone")
  end

  test "a hash smuggled in as the phone is ignored" do
    post session_path, params: { with: "phone", phone: { "$ne" => "" }, password: "password" }
    assert_redirected_to new_session_path(with: "phone")
    assert_nil cookies[:session_id]
  end

  test "a logged-in owner is redirected away from the login page" do
    sign_in_as @user
    get new_session_path
    assert_redirected_to root_path
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
