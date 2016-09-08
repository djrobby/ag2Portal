require 'test_helper'

module Ag2Gest
  class ServicePointPurposesControllerTest < ActionController::TestCase
    setup do
      @service_point_purpose = service_point_purposes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:service_point_purposes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create service_point_purpose" do
      assert_difference('ServicePointPurpose.count') do
        post :create, service_point_purpose: {  }
      end
  
      assert_redirected_to service_point_purpose_path(assigns(:service_point_purpose))
    end
  
    test "should show service_point_purpose" do
      get :show, id: @service_point_purpose
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @service_point_purpose
      assert_response :success
    end
  
    test "should update service_point_purpose" do
      put :update, id: @service_point_purpose, service_point_purpose: {  }
      assert_redirected_to service_point_purpose_path(assigns(:service_point_purpose))
    end
  
    test "should destroy service_point_purpose" do
      assert_difference('ServicePointPurpose.count', -1) do
        delete :destroy, id: @service_point_purpose
      end
  
      assert_redirected_to service_point_purposes_path
    end
  end
end
