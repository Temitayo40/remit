require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "logged-in owners see their own name" do
    sign_in_as users(:one)
    get root_path

    assert_response :success
    assert_select "h1", /Ada Okafor/
  end

  test "after logging in, the owner returns to the page they asked for" do
    get root_path # remembered as the return_to url
    post session_path, params: { phone: "08031234567", password: "password" }
    assert_redirected_to root_url
  end
end
