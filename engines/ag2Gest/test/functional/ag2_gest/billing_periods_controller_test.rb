require 'test_helper'

module Ag2Gest
  class BillingPeriodsControllerTest < ActionController::TestCase
    setup do
      @billing_period = billing_periods(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:billing_periods)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create billing_period" do
      assert_difference('BillingPeriod.count') do
        post :create, billing_period: {  }
      end
  
      assert_redirected_to billing_period_path(assigns(:billing_period))
    end
  
    test "should show billing_period" do
      get :show, id: @billing_period
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @billing_period
      assert_response :success
    end
  
    test "should update billing_period" do
      put :update, id: @billing_period, billing_period: {  }
      assert_redirected_to billing_period_path(assigns(:billing_period))
    end
  
    test "should destroy billing_period" do
      assert_difference('BillingPeriod.count', -1) do
        delete :destroy, id: @billing_period
      end
  
      assert_redirected_to billing_periods_path
    end
  end
end
