require 'test_helper'

module Ag2Gest
  class ContractTemplatesControllerTest < ActionController::TestCase
    setup do
      @contract_template = contract_templates(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contract_templates)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contract_template" do
      assert_difference('ContractTemplate.count') do
        post :create, contract_template: {  }
      end
  
      assert_redirected_to contract_template_path(assigns(:contract_template))
    end
  
    test "should show contract_template" do
      get :show, id: @contract_template
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contract_template
      assert_response :success
    end
  
    test "should update contract_template" do
      put :update, id: @contract_template, contract_template: {  }
      assert_redirected_to contract_template_path(assigns(:contract_template))
    end
  
    test "should destroy contract_template" do
      assert_difference('ContractTemplate.count', -1) do
        delete :destroy, id: @contract_template
      end
  
      assert_redirected_to contract_templates_path
    end
  end
end
