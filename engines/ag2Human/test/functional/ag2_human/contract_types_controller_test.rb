require 'test_helper'

module Ag2Human
  class ContractTypesControllerTest < ActionController::TestCase
    setup do
      @contract_type = contract_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contract_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contract_type" do
      assert_difference('ContractType.count') do
        post :create, contract_type: {  }
      end
  
      assert_redirected_to contract_type_path(assigns(:contract_type))
    end
  
    test "should show contract_type" do
      get :show, id: @contract_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contract_type
      assert_response :success
    end
  
    test "should update contract_type" do
      put :update, id: @contract_type, contract_type: {  }
      assert_redirected_to contract_type_path(assigns(:contract_type))
    end
  
    test "should destroy contract_type" do
      assert_difference('ContractType.count', -1) do
        delete :destroy, id: @contract_type
      end
  
      assert_redirected_to contract_types_path
    end
  end
end
