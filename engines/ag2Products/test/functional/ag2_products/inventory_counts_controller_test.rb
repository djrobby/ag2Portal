require 'test_helper'

module Ag2Products
  class InventoryCountsControllerTest < ActionController::TestCase
    setup do
      @inventory_count = inventory_counts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:inventory_counts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create inventory_count" do
      assert_difference('InventoryCount.count') do
        post :create, inventory_count: {  }
      end
  
      assert_redirected_to inventory_count_path(assigns(:inventory_count))
    end
  
    test "should show inventory_count" do
      get :show, id: @inventory_count
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @inventory_count
      assert_response :success
    end
  
    test "should update inventory_count" do
      put :update, id: @inventory_count, inventory_count: {  }
      assert_redirected_to inventory_count_path(assigns(:inventory_count))
    end
  
    test "should destroy inventory_count" do
      assert_difference('InventoryCount.count', -1) do
        delete :destroy, id: @inventory_count
      end
  
      assert_redirected_to inventory_counts_path
    end
  end
end
