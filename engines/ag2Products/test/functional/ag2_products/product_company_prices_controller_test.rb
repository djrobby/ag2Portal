require 'test_helper'

module Ag2Products
  class ProductCompanyPricesControllerTest < ActionController::TestCase
    setup do
      @product_company_price = product_company_prices(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:product_company_prices)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create product_company_price" do
      assert_difference('ProductCompanyPrice.count') do
        post :create, product_company_price: {  }
      end
  
      assert_redirected_to product_company_price_path(assigns(:product_company_price))
    end
  
    test "should show product_company_price" do
      get :show, id: @product_company_price
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @product_company_price
      assert_response :success
    end
  
    test "should update product_company_price" do
      put :update, id: @product_company_price, product_company_price: {  }
      assert_redirected_to product_company_price_path(assigns(:product_company_price))
    end
  
    test "should destroy product_company_price" do
      assert_difference('ProductCompanyPrice.count', -1) do
        delete :destroy, id: @product_company_price
      end
  
      assert_redirected_to product_company_prices_path
    end
  end
end
