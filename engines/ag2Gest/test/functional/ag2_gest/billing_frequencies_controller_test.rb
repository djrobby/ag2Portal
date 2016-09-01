require 'test_helper'

module Ag2Gest
  class BillingFrequenciesControllerTest < ActionController::TestCase
    setup do
      @billing_frequency = billing_frequencies(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:billing_frequencies)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create billing_frequency" do
      assert_difference('BillingFrequency.count') do
        post :create, billing_frequency: {  }
      end
  
      assert_redirected_to billing_frequency_path(assigns(:billing_frequency))
    end
  
    test "should show billing_frequency" do
      get :show, id: @billing_frequency
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @billing_frequency
      assert_response :success
    end
  
    test "should update billing_frequency" do
      put :update, id: @billing_frequency, billing_frequency: {  }
      assert_redirected_to billing_frequency_path(assigns(:billing_frequency))
    end
  
    test "should destroy billing_frequency" do
      assert_difference('BillingFrequency.count', -1) do
        delete :destroy, id: @billing_frequency
      end
  
      assert_redirected_to billing_frequencies_path
    end
  end
end
