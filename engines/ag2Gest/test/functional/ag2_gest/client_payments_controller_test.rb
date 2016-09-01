require 'test_helper'

module Ag2Gest
  class ClientPaymentsControllerTest < ActionController::TestCase
    setup do
      @client_payment = client_payments(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:client_payments)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create client_payment" do
      assert_difference('ClientPayment.count') do
        post :create, client_payment: {  }
      end
  
      assert_redirected_to client_payment_path(assigns(:client_payment))
    end
  
    test "should show client_payment" do
      get :show, id: @client_payment
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @client_payment
      assert_response :success
    end
  
    test "should update client_payment" do
      put :update, id: @client_payment, client_payment: {  }
      assert_redirected_to client_payment_path(assigns(:client_payment))
    end
  
    test "should destroy client_payment" do
      assert_difference('ClientPayment.count', -1) do
        delete :destroy, id: @client_payment
      end
  
      assert_redirected_to client_payments_path
    end
  end
end
