require 'test_helper'

module Ag2Products
  class InventoryCountTypesControllerTest < ActionController::TestCase
    setup do
      @inventory_count_type = inventory_count_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:inventory_count_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create inventory_count_type" do
      assert_difference('InventoryCountType.count') do
        post :create, inventory_count_type: {  }
      end
  
      assert_redirected_to inventory_count_type_path(assigns(:inventory_count_type))
    end
  
    test "should show inventory_count_type" do
      get :show, id: @inventory_count_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @inventory_count_type
      assert_response :success
    end
  
    test "should update inventory_count_type" do
      put :update, id: @inventory_count_type, inventory_count_type: {  }
      assert_redirected_to inventory_count_type_path(assigns(:inventory_count_type))
    end
  
    test "should destroy inventory_count_type" do
      assert_difference('InventoryCountType.count', -1) do
        delete :destroy, id: @inventory_count_type
      end
  
      assert_redirected_to inventory_count_types_path
    end
  end
end
