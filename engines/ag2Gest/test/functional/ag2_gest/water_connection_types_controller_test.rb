require 'test_helper'

module Ag2Gest
  class WaterConnectionTypesControllerTest < ActionController::TestCase
    setup do
      @water_connection_type = water_connection_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:water_connection_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create water_connection_type" do
      assert_difference('WaterConnectionType.count') do
        post :create, water_connection_type: {  }
      end
  
      assert_redirected_to water_connection_type_path(assigns(:water_connection_type))
    end
  
    test "should show water_connection_type" do
      get :show, id: @water_connection_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @water_connection_type
      assert_response :success
    end
  
    test "should update water_connection_type" do
      put :update, id: @water_connection_type, water_connection_type: {  }
      assert_redirected_to water_connection_type_path(assigns(:water_connection_type))
    end
  
    test "should destroy water_connection_type" do
      assert_difference('WaterConnectionType.count', -1) do
        delete :destroy, id: @water_connection_type
      end
  
      assert_redirected_to water_connection_types_path
    end
  end
end
