require 'test_helper'

module Ag2Gest
  class ComplaintDocumentTypesControllerTest < ActionController::TestCase
    setup do
      @complaint_document_type = complaint_document_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:complaint_document_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create complaint_document_type" do
      assert_difference('ComplaintDocumentType.count') do
        post :create, complaint_document_type: {  }
      end
  
      assert_redirected_to complaint_document_type_path(assigns(:complaint_document_type))
    end
  
    test "should show complaint_document_type" do
      get :show, id: @complaint_document_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @complaint_document_type
      assert_response :success
    end
  
    test "should update complaint_document_type" do
      put :update, id: @complaint_document_type, complaint_document_type: {  }
      assert_redirected_to complaint_document_type_path(assigns(:complaint_document_type))
    end
  
    test "should destroy complaint_document_type" do
      assert_difference('ComplaintDocumentType.count', -1) do
        delete :destroy, id: @complaint_document_type
      end
  
      assert_redirected_to complaint_document_types_path
    end
  end
end
