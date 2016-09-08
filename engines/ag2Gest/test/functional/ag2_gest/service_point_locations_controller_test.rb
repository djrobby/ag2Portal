require 'test_helper'

module Ag2Gest
  class ServicePointLocationsControllerTest < ActionController::TestCase
    setup do
      @service_point_location = service_point_locations(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:service_point_locations)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create service_point_location" do
      assert_difference('ServicePointLocation.count') do
        post :create, service_point_location: {  }
      end
  
      assert_redirected_to service_point_location_path(assigns(:service_point_location))
    end
  
    test "should show service_point_location" do
      get :show, id: @service_point_location
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @service_point_location
      assert_response :success
    end
  
    test "should update service_point_location" do
      put :update, id: @service_point_location, service_point_location: {  }
      assert_redirected_to service_point_location_path(assigns(:service_point_location))
    end
  
    test "should destroy service_point_location" do
      assert_difference('ServicePointLocation.count', -1) do
        delete :destroy, id: @service_point_location
      end
  
      assert_redirected_to service_point_locations_path
    end
  end
end
