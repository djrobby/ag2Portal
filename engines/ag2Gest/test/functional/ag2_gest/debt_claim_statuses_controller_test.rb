require 'test_helper'

module Ag2Gest
  class DebtClaimStatusesControllerTest < ActionController::TestCase
    setup do
      @debt_claim_status = debt_claim_statuses(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:debt_claim_statuses)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create debt_claim_status" do
      assert_difference('DebtClaimStatus.count') do
        post :create, debt_claim_status: {  }
      end
  
      assert_redirected_to debt_claim_status_path(assigns(:debt_claim_status))
    end
  
    test "should show debt_claim_status" do
      get :show, id: @debt_claim_status
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @debt_claim_status
      assert_response :success
    end
  
    test "should update debt_claim_status" do
      put :update, id: @debt_claim_status, debt_claim_status: {  }
      assert_redirected_to debt_claim_status_path(assigns(:debt_claim_status))
    end
  
    test "should destroy debt_claim_status" do
      assert_difference('DebtClaimStatus.count', -1) do
        delete :destroy, id: @debt_claim_status
      end
  
      assert_redirected_to debt_claim_statuses_path
    end
  end
end
