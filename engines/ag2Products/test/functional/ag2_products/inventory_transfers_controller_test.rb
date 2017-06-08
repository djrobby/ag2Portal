require 'test_helper'

module Ag2Products
  class InventoryTransfersControllerTest < ActionController::TestCase
    setup do
      @inventory_transfer = inventory_transfers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:inventory_transfers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create inventory_transfer" do
      assert_difference('InventoryTransfer.count') do
        post :create, inventory_transfer: {  }
      end
  
      assert_redirected_to inventory_transfer_path(assigns(:inventory_transfer))
    end
  
    test "should show inventory_transfer" do
      get :show, id: @inventory_transfer
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @inventory_transfer
      assert_response :success
    end
  
    test "should update inventory_transfer" do
      put :update, id: @inventory_transfer, inventory_transfer: {  }
      assert_redirected_to inventory_transfer_path(assigns(:inventory_transfer))
    end
  
    test "should destroy inventory_transfer" do
      assert_difference('InventoryTransfer.count', -1) do
        delete :destroy, id: @inventory_transfer
      end
  
      assert_redirected_to inventory_transfers_path
    end
  end
end
