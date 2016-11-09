require 'test_helper'

module Ag2Gest
  class ComplaintStatusesControllerTest < ActionController::TestCase
    setup do
      @complaint_status = complaint_statuses(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:complaint_statuses)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create complaint_status" do
      assert_difference('ComplaintStatus.count') do
        post :create, complaint_status: {  }
      end
  
      assert_redirected_to complaint_status_path(assigns(:complaint_status))
    end
  
    test "should show complaint_status" do
      get :show, id: @complaint_status
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @complaint_status
      assert_response :success
    end
  
    test "should update complaint_status" do
      put :update, id: @complaint_status, complaint_status: {  }
      assert_redirected_to complaint_status_path(assigns(:complaint_status))
    end
  
    test "should destroy complaint_status" do
      assert_difference('ComplaintStatus.count', -1) do
        delete :destroy, id: @complaint_status
      end
  
      assert_redirected_to complaint_statuses_path
    end
  end
end
