require 'test_helper'

module Ag2Gest
  class ContractingRequestStatusesControllerTest < ActionController::TestCase
    setup do
      @contracting_request_status = contracting_request_statuses(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:contracting_request_statuses)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create contracting_request_status" do
      assert_difference('ContractingRequestStatus.count') do
        post :create, contracting_request_status: {  }
      end
  
      assert_redirected_to contracting_request_status_path(assigns(:contracting_request_status))
    end
  
    test "should show contracting_request_status" do
      get :show, id: @contracting_request_status
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @contracting_request_status
      assert_response :success
    end
  
    test "should update contracting_request_status" do
      put :update, id: @contracting_request_status, contracting_request_status: {  }
      assert_redirected_to contracting_request_status_path(assigns(:contracting_request_status))
    end
  
    test "should destroy contracting_request_status" do
      assert_difference('ContractingRequestStatus.count', -1) do
        delete :destroy, id: @contracting_request_status
      end
  
      assert_redirected_to contracting_request_statuses_path
    end
  end
end
