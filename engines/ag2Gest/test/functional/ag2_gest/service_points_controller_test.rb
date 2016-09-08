require 'test_helper'

module Ag2Gest
  class ServicePointsControllerTest < ActionController::TestCase
    setup do
      @service_point = service_points(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:service_points)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create service_point" do
      assert_difference('ServicePoint.count') do
        post :create, service_point: {  }
      end
  
      assert_redirected_to service_point_path(assigns(:service_point))
    end
  
    test "should show service_point" do
      get :show, id: @service_point
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @service_point
      assert_response :success
    end
  
    test "should update service_point" do
      put :update, id: @service_point, service_point: {  }
      assert_redirected_to service_point_path(assigns(:service_point))
    end
  
    test "should destroy service_point" do
      assert_difference('ServicePoint.count', -1) do
        delete :destroy, id: @service_point
      end
  
      assert_redirected_to service_points_path
    end
  end
end
