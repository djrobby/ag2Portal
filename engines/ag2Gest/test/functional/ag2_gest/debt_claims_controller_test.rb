require 'test_helper'

module Ag2Gest
  class DebtClaimsControllerTest < ActionController::TestCase
    setup do
      @debt_claim = debt_claims(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:debt_claims)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create debt_claim" do
      assert_difference('DebtClaim.count') do
        post :create, debt_claim: {  }
      end
  
      assert_redirected_to debt_claim_path(assigns(:debt_claim))
    end
  
    test "should show debt_claim" do
      get :show, id: @debt_claim
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @debt_claim
      assert_response :success
    end
  
    test "should update debt_claim" do
      put :update, id: @debt_claim, debt_claim: {  }
      assert_redirected_to debt_claim_path(assigns(:debt_claim))
    end
  
    test "should destroy debt_claim" do
      assert_difference('DebtClaim.count', -1) do
        delete :destroy, id: @debt_claim
      end
  
      assert_redirected_to debt_claims_path
    end
  end
end
