require 'test_helper'

module Ag2Tech
  class WorkOrderAreasControllerTest < ActionController::TestCase
    setup do
      @work_order_area = work_order_areas(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:work_order_areas)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create work_order_area" do
      assert_difference('WorkOrderArea.count') do
        post :create, work_order_area: {  }
      end
  
      assert_redirected_to work_order_area_path(assigns(:work_order_area))
    end
  
    test "should show work_order_area" do
      get :show, id: @work_order_area
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @work_order_area
      assert_response :success
    end
  
    test "should update work_order_area" do
      put :update, id: @work_order_area, work_order_area: {  }
      assert_redirected_to work_order_area_path(assigns(:work_order_area))
    end
  
    test "should destroy work_order_area" do
      assert_difference('WorkOrderArea.count', -1) do
        delete :destroy, id: @work_order_area
      end
  
      assert_redirected_to work_order_areas_path
    end
  end
end
