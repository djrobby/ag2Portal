require 'test_helper'

module Ag2Tech
  class ChargeAccountsControllerTest < ActionController::TestCase
    setup do
      @charge_account = charge_accounts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:charge_accounts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create charge_account" do
      assert_difference('ChargeAccount.count') do
        post :create, charge_account: {  }
      end
  
      assert_redirected_to charge_account_path(assigns(:charge_account))
    end
  
    test "should show charge_account" do
      get :show, id: @charge_account
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @charge_account
      assert_response :success
    end
  
    test "should update charge_account" do
      put :update, id: @charge_account, charge_account: {  }
      assert_redirected_to charge_account_path(assigns(:charge_account))
    end
  
    test "should destroy charge_account" do
      assert_difference('ChargeAccount.count', -1) do
        delete :destroy, id: @charge_account
      end
  
      assert_redirected_to charge_accounts_path
    end
  end
end
