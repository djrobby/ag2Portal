require 'test_helper'

module Ag2Gest
  class DebtClaimPhasesControllerTest < ActionController::TestCase
    setup do
      @debt_claim_phase = debt_claim_phases(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:debt_claim_phases)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create debt_claim_phase" do
      assert_difference('DebtClaimPhase.count') do
        post :create, debt_claim_phase: {  }
      end
  
      assert_redirected_to debt_claim_phase_path(assigns(:debt_claim_phase))
    end
  
    test "should show debt_claim_phase" do
      get :show, id: @debt_claim_phase
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @debt_claim_phase
      assert_response :success
    end
  
    test "should update debt_claim_phase" do
      put :update, id: @debt_claim_phase, debt_claim_phase: {  }
      assert_redirected_to debt_claim_phase_path(assigns(:debt_claim_phase))
    end
  
    test "should destroy debt_claim_phase" do
      assert_difference('DebtClaimPhase.count', -1) do
        delete :destroy, id: @debt_claim_phase
      end
  
      assert_redirected_to debt_claim_phases_path
    end
  end
end
