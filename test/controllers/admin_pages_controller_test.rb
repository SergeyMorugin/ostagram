require 'test_helper'

class AdminPagesControllerTest < ActionController::TestCase
  test "should get main" do
    get :main
    assert_response :success
  end

  test "should get images" do
    get :images
    assert_response :success
  end

  test "should get users" do
    get :users
    assert_response :success
  end

end
