require 'test_helper'

module Ag2Tech
  class WorkOrderTypesControllerTest < ActionController::TestCase
    setup do
      @work_order_type = work_order_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:work_order_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create work_order_type" do
      assert_difference('WorkOrderType.count') do
        post :create, work_order_type: {  }
      end
  
      assert_redirected_to work_order_type_path(assigns(:work_order_type))
    end
  
    test "should show work_order_type" do
      get :show, id: @work_order_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @work_order_type
      assert_response :success
    end
  
    test "should update work_order_type" do
      put :update, id: @work_order_type, work_order_type: {  }
      assert_redirected_to work_order_type_path(assigns(:work_order_type))
    end
  
    test "should destroy work_order_type" do
      assert_difference('WorkOrderType.count', -1) do
        delete :destroy, id: @work_order_type
      end
  
      assert_redirected_to work_order_types_path
    end
  end
end
