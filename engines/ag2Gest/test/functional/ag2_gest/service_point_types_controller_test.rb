require 'test_helper'

module Ag2Gest
  class ServicePointTypesControllerTest < ActionController::TestCase
    setup do
      @service_point_type = service_point_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:service_point_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create service_point_type" do
      assert_difference('ServicePointType.count') do
        post :create, service_point_type: {  }
      end
  
      assert_redirected_to service_point_type_path(assigns(:service_point_type))
    end
  
    test "should show service_point_type" do
      get :show, id: @service_point_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @service_point_type
      assert_response :success
    end
  
    test "should update service_point_type" do
      put :update, id: @service_point_type, service_point_type: {  }
      assert_redirected_to service_point_type_path(assigns(:service_point_type))
    end
  
    test "should destroy service_point_type" do
      assert_difference('ServicePointType.count', -1) do
        delete :destroy, id: @service_point_type
      end
  
      assert_redirected_to service_point_types_path
    end
  end
end
