require 'test_helper'

module Ag2Tech
  class WorkOrderStatusesControllerTest < ActionController::TestCase
    setup do
      @work_order_status = work_order_statuses(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:work_order_statuses)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create work_order_status" do
      assert_difference('WorkOrderStatus.count') do
        post :create, work_order_status: {  }
      end
  
      assert_redirected_to work_order_status_path(assigns(:work_order_status))
    end
  
    test "should show work_order_status" do
      get :show, id: @work_order_status
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @work_order_status
      assert_response :success
    end
  
    test "should update work_order_status" do
      put :update, id: @work_order_status, work_order_status: {  }
      assert_redirected_to work_order_status_path(assigns(:work_order_status))
    end
  
    test "should destroy work_order_status" do
      assert_difference('WorkOrderStatus.count', -1) do
        delete :destroy, id: @work_order_status
      end
  
      assert_redirected_to work_order_statuses_path
    end
  end
end
