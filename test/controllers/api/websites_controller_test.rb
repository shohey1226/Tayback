require 'test_helper'

class Api::WebsitesControllerTest < ActionController::TestCase
  setup do
    @api_website = api_websites(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:api_websites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create api_website" do
    assert_difference('Api::Website.count') do
      post :create, api_website: {  }
    end

    assert_redirected_to api_website_path(assigns(:api_website))
  end

  test "should show api_website" do
    get :show, id: @api_website
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @api_website
    assert_response :success
  end

  test "should update api_website" do
    patch :update, id: @api_website, api_website: {  }
    assert_redirected_to api_website_path(assigns(:api_website))
  end

  test "should destroy api_website" do
    assert_difference('Api::Website.count', -1) do
      delete :destroy, id: @api_website
    end

    assert_redirected_to api_websites_path
  end
end
