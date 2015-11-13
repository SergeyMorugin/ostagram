require 'test_helper'

class QueueImagesControllerTest < ActionController::TestCase
  setup do
    @queue_image = queue_images(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:queue_images)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create queue_image" do
    assert_difference('QueueImage.count') do
      post :create, queue_image: { content_image: @queue_image.content_image, init_str: @queue_image.init_str, result: @queue_image.result, status: @queue_image.status, style_image: @queue_image.style_image, user_id: @queue_image.user_id }
    end

    assert_redirected_to queue_image_path(assigns(:queue_image))
  end

  test "should show queue_image" do
    get :show, id: @queue_image
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @queue_image
    assert_response :success
  end

  test "should update queue_image" do
    patch :update, id: @queue_image, queue_image: { content_image: @queue_image.content_image, init_str: @queue_image.init_str, result: @queue_image.result, status: @queue_image.status, style_image: @queue_image.style_image, user_id: @queue_image.user_id }
    assert_redirected_to queue_image_path(assigns(:queue_image))
  end

  test "should destroy queue_image" do
    assert_difference('QueueImage.count', -1) do
      delete :destroy, id: @queue_image
    end

    assert_redirected_to queue_images_path
  end
end
