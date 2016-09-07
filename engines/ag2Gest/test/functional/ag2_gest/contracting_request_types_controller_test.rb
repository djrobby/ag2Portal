require 'test_helper'

module Ag2Gest
  class ContractingRequestTypesControllerTest < ActionController::TestCase
    setup do
      @contracting_request_type = contracting_request_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contracting_request_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contracting_request_type" do
      assert_difference('ContractingRequestType.count') do
        post :create, contracting_request_type: {  }
      end
  
      assert_redirected_to contracting_request_type_path(assigns(:contracting_request_type))
    end
  
    test "should show contracting_request_type" do
      get :show, id: @contracting_request_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contracting_request_type
      assert_response :success
    end
  
    test "should update contracting_request_type" do
      put :update, id: @contracting_request_type, contracting_request_type: {  }
      assert_redirected_to contracting_request_type_path(assigns(:contracting_request_type))
    end
  
    test "should destroy contracting_request_type" do
      assert_difference('ContractingRequestType.count', -1) do
        delete :destroy, id: @contracting_request_type
      end
  
      assert_redirected_to contracting_request_types_path
    end
  end
end
