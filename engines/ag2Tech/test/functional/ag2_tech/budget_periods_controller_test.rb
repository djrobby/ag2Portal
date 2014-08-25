require 'test_helper'

module Ag2Tech
  class BudgetPeriodsControllerTest < ActionController::TestCase
    setup do
      @budget_period = budget_periods(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:budget_periods)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create budget_period" do
      assert_difference('BudgetPeriod.count') do
        post :create, budget_period: {  }
      end
  
      assert_redirected_to budget_period_path(assigns(:budget_period))
    end
  
    test "should show budget_period" do
      get :show, id: @budget_period
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @budget_period
      assert_response :success
    end
  
    test "should update budget_period" do
      put :update, id: @budget_period, budget_period: {  }
      assert_redirected_to budget_period_path(assigns(:budget_period))
    end
  
    test "should destroy budget_period" do
      assert_difference('BudgetPeriod.count', -1) do
        delete :destroy, id: @budget_period
      end
  
      assert_redirected_to budget_periods_path
    end
  end
end
