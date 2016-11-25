require 'test_helper'

module Ag2Gest
  class CommercialBillingsControllerTest < ActionController::TestCase
    setup do
      @commercial_billing = commercial_billings(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:commercial_billings)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create commercial_billing" do
      assert_difference('CommercialBilling.count') do
        post :create, commercial_billing: {  }
      end
  
      assert_redirected_to commercial_billing_path(assigns(:commercial_billing))
    end
  
    test "should show commercial_billing" do
      get :show, id: @commercial_billing
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @commercial_billing
      assert_response :success
    end
  
    test "should update commercial_billing" do
      put :update, id: @commercial_billing, commercial_billing: {  }
      assert_redirected_to commercial_billing_path(assigns(:commercial_billing))
    end
  
    test "should destroy commercial_billing" do
      assert_difference('CommercialBilling.count', -1) do
        delete :destroy, id: @commercial_billing
      end
  
      assert_redirected_to commercial_billings_path
    end
  end
end
