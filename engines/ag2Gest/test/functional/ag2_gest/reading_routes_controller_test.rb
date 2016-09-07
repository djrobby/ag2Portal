require 'test_helper'

module Ag2Gest
  class ReadingRoutesControllerTest < ActionController::TestCase
    setup do
      @reading_route = reading_routes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:reading_routes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create reading_route" do
      assert_difference('ReadingRoute.count') do
        post :create, reading_route: {  }
      end
  
      assert_redirected_to reading_route_path(assigns(:reading_route))
    end
  
    test "should show reading_route" do
      get :show, id: @reading_route
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @reading_route
      assert_response :success
    end
  
    test "should update reading_route" do
      put :update, id: @reading_route, reading_route: {  }
      assert_redirected_to reading_route_path(assigns(:reading_route))
    end
  
    test "should destroy reading_route" do
      assert_difference('ReadingRoute.count', -1) do
        delete :destroy, id: @reading_route
      end
  
      assert_redirected_to reading_routes_path
    end
  end
end
