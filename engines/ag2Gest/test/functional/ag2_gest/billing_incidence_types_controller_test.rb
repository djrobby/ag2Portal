require 'test_helper'

module Ag2Gest
  class BillingIncidenceTypesControllerTest < ActionController::TestCase
    setup do
      @billing_incidence_type = billing_incidence_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:billing_incidence_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create billing_incidence_type" do
      assert_difference('BillingIncidenceType.count') do
        post :create, billing_incidence_type: {  }
      end
  
      assert_redirected_to billing_incidence_type_path(assigns(:billing_incidence_type))
    end
  
    test "should show billing_incidence_type" do
      get :show, id: @billing_incidence_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @billing_incidence_type
      assert_response :success
    end
  
    test "should update billing_incidence_type" do
      put :update, id: @billing_incidence_type, billing_incidence_type: {  }
      assert_redirected_to billing_incidence_type_path(assigns(:billing_incidence_type))
    end
  
    test "should destroy billing_incidence_type" do
      assert_difference('BillingIncidenceType.count', -1) do
        delete :destroy, id: @billing_incidence_type
      end
  
      assert_redirected_to billing_incidence_types_path
    end
  end
end
