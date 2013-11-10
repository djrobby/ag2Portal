require 'test_helper'

module Ag2Products
  class PurchasePricesControllerTest < ActionController::TestCase
    setup do
      @purchase_price = purchase_prices(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:purchase_prices)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create purchase_price" do
      assert_difference('PurchasePrice.count') do
        post :create, purchase_price: {  }
      end
  
      assert_redirected_to purchase_price_path(assigns(:purchase_price))
    end
  
    test "should show purchase_price" do
      get :show, id: @purchase_price
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @purchase_price
      assert_response :success
    end
  
    test "should update purchase_price" do
      put :update, id: @purchase_price, purchase_price: {  }
      assert_redirected_to purchase_price_path(assigns(:purchase_price))
    end
  
    test "should destroy purchase_price" do
      assert_difference('PurchasePrice.count', -1) do
        delete :destroy, id: @purchase_price
      end
  
      assert_redirected_to purchase_prices_path
    end
  end
end
