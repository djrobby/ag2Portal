require 'test_helper'

module Ag2Gest
  class WaterConnectionsControllerTest < ActionController::TestCase
    setup do
      @water_connection = water_connections(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:water_connections)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create water_connection" do
      assert_difference('WaterConnection.count') do
        post :create, water_connection: {  }
      end
  
      assert_redirected_to water_connection_path(assigns(:water_connection))
    end
  
    test "should show water_connection" do
      get :show, id: @water_connection
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @water_connection
      assert_response :success
    end
  
    test "should update water_connection" do
      put :update, id: @water_connection, water_connection: {  }
      assert_redirected_to water_connection_path(assigns(:water_connection))
    end
  
    test "should destroy water_connection" do
      assert_difference('WaterConnection.count', -1) do
        delete :destroy, id: @water_connection
      end
  
      assert_redirected_to water_connections_path
    end
  end
end
