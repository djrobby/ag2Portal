require 'test_helper'

module Ag2Gest
  class ContractTemplateTermsControllerTest < ActionController::TestCase
    setup do
      @contract_template_term = contract_template_terms(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contract_template_terms)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contract_template_term" do
      assert_difference('ContractTemplateTerm.count') do
        post :create, contract_template_term: {  }
      end
  
      assert_redirected_to contract_template_term_path(assigns(:contract_template_term))
    end
  
    test "should show contract_template_term" do
      get :show, id: @contract_template_term
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contract_template_term
      assert_response :success
    end
  
    test "should update contract_template_term" do
      put :update, id: @contract_template_term, contract_template_term: {  }
      assert_redirected_to contract_template_term_path(assigns(:contract_template_term))
    end
  
    test "should destroy contract_template_term" do
      assert_difference('ContractTemplateTerm.count', -1) do
        delete :destroy, id: @contract_template_term
      end
  
      assert_redirected_to contract_template_terms_path
    end
  end
end
