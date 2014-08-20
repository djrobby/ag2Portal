require 'test_helper'

module Ag2Gest
  class SaleOffersControllerTest < ActionController::TestCase
    setup do
      @sale_offer = sale_offers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:sale_offers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create sale_offer" do
      assert_difference('SaleOffer.count') do
        post :create, sale_offer: {  }
      end
  
      assert_redirected_to sale_offer_path(assigns(:sale_offer))
    end
  
    test "should show sale_offer" do
      get :show, id: @sale_offer
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @sale_offer
      assert_response :success
    end
  
    test "should update sale_offer" do
      put :update, id: @sale_offer, sale_offer: {  }
      assert_redirected_to sale_offer_path(assigns(:sale_offer))
    end
  
    test "should destroy sale_offer" do
      assert_difference('SaleOffer.count', -1) do
        delete :destroy, id: @sale_offer
      end
  
      assert_redirected_to sale_offers_path
    end
  end
end
