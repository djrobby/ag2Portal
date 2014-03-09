require 'test_helper'

module Ag2Tech
  class WorkOrderLaborsControllerTest < ActionController::TestCase
    setup do
      @work_order_labor = work_order_labors(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:work_order_labors)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create work_order_labor" do
      assert_difference('WorkOrderLabor.count') do
        post :create, work_order_labor: {  }
      end
  
      assert_redirected_to work_order_labor_path(assigns(:work_order_labor))
    end
  
    test "should show work_order_labor" do
      get :show, id: @work_order_labor
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @work_order_labor
      assert_response :success
    end
  
    test "should update work_order_labor" do
      put :update, id: @work_order_labor, work_order_labor: {  }
      assert_redirected_to work_order_labor_path(assigns(:work_order_labor))
    end
  
    test "should destroy work_order_labor" do
      assert_difference('WorkOrderLabor.count', -1) do
        delete :destroy, id: @work_order_labor
      end
  
      assert_redirected_to work_order_labors_path
    end
  end
end
