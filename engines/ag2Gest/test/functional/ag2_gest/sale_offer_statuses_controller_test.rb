require 'test_helper'

module Ag2Gest
  class SaleOfferStatusesControllerTest < ActionController::TestCase
    setup do
      @sale_offer_status = sale_offer_statuses(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:sale_offer_statuses)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create sale_offer_status" do
      assert_difference('SaleOfferStatus.count') do
        post :create, sale_offer_status: {  }
      end
  
      assert_redirected_to sale_offer_status_path(assigns(:sale_offer_status))
    end
  
    test "should show sale_offer_status" do
      get :show, id: @sale_offer_status
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @sale_offer_status
      assert_response :success
    end
  
    test "should update sale_offer_status" do
      put :update, id: @sale_offer_status, sale_offer_status: {  }
      assert_redirected_to sale_offer_status_path(assigns(:sale_offer_status))
    end
  
    test "should destroy sale_offer_status" do
      assert_difference('SaleOfferStatus.count', -1) do
        delete :destroy, id: @sale_offer_status
      end
  
      assert_redirected_to sale_offer_statuses_path
    end
  end
end
