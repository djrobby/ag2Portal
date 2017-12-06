require 'test_helper'

module Ag2Admin
  class CashMovementTypesControllerTest < ActionController::TestCase
    setup do
      @cash_movement_type = cash_movement_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:cash_movement_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create cash_movement_type" do
      assert_difference('CashMovementType.count') do
        post :create, cash_movement_type: {  }
      end
  
      assert_redirected_to cash_movement_type_path(assigns(:cash_movement_type))
    end
  
    test "should show cash_movement_type" do
      get :show, id: @cash_movement_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @cash_movement_type
      assert_response :success
    end
  
    test "should update cash_movement_type" do
      put :update, id: @cash_movement_type, cash_movement_type: {  }
      assert_redirected_to cash_movement_type_path(assigns(:cash_movement_type))
    end
  
    test "should destroy cash_movement_type" do
      assert_difference('CashMovementType.count', -1) do
        delete :destroy, id: @cash_movement_type
      end
  
      assert_redirected_to cash_movement_types_path
    end
  end
end
