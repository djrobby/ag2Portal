require 'test_helper'

module Ag2Gest
  class ContractingRequestsControllerTest < ActionController::TestCase
    setup do
      @contracting_request = contracting_requests(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contracting_requests)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contracting_request" do
      assert_difference('ContractingRequest.count') do
        post :create, contracting_request: {  }
      end
  
      assert_redirected_to contracting_request_path(assigns(:contracting_request))
    end
  
    test "should show contracting_request" do
      get :show, id: @contracting_request
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contracting_request
      assert_response :success
    end
  
    test "should update contracting_request" do
      put :update, id: @contracting_request, contracting_request: {  }
      assert_redirected_to contracting_request_path(assigns(:contracting_request))
    end
  
    test "should destroy contracting_request" do
      assert_difference('ContractingRequest.count', -1) do
        delete :destroy, id: @contracting_request
      end
  
      assert_redirected_to contracting_requests_path
    end
  end
end
