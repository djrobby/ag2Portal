require 'test_helper'

module Ag2Gest
  class MeterLocationsControllerTest < ActionController::TestCase
    setup do
      @meter_location = meter_locations(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:meter_locations)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create meter_location" do
      assert_difference('MeterLocation.count') do
        post :create, meter_location: {  }
      end
  
      assert_redirected_to meter_location_path(assigns(:meter_location))
    end
  
    test "should show meter_location" do
      get :show, id: @meter_location
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @meter_location
      assert_response :success
    end
  
    test "should update meter_location" do
      put :update, id: @meter_location, meter_location: {  }
      assert_redirected_to meter_location_path(assigns(:meter_location))
    end
  
    test "should destroy meter_location" do
      assert_difference('MeterLocation.count', -1) do
        delete :destroy, id: @meter_location
      end
  
      assert_redirected_to meter_locations_path
    end
  end
end
