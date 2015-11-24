require 'test_helper'

class S1tylesControllerTest < ActionController::TestCase
  setup do
    @s1tyle = s1tyles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:s1tyles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create s1tyle" do
    assert_difference('S1tyle.count') do
      post :create, s1tyle: { image: @s1tyle.image, init: @s1tyle.init, status: @s1tyle.status, use_counter: @s1tyle.use_counter }
    end

    assert_redirected_to s1tyle_path(assigns(:s1tyle))
  end

  test "should show s1tyle" do
    get :show, id: @s1tyle
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @s1tyle
    assert_response :success
  end

  test "should update s1tyle" do
    patch :update, id: @s1tyle, s1tyle: { image: @s1tyle.image, init: @s1tyle.init, status: @s1tyle.status, use_counter: @s1tyle.use_counter }
    assert_redirected_to s1tyle_path(assigns(:s1tyle))
  end

  test "should destroy s1tyle" do
    assert_difference('S1tyle.count', -1) do
      delete :destroy, id: @s1tyle
    end

    assert_redirected_to s1tyles_path
  end
end
