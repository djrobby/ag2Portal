require 'test_helper'

module Ag2Directory
  class CorpContactsControllerTest < ActionController::TestCase
    setup do
      @corp_contact = corp_contacts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:corp_contacts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create corp_contact" do
      assert_difference('CorpContact.count') do
        post :create, corp_contact: {  }
      end
  
      assert_redirected_to corp_contact_path(assigns(:corp_contact))
    end
  
    test "should show corp_contact" do
      get :show, id: @corp_contact
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @corp_contact
      assert_response :success
    end
  
    test "should update corp_contact" do
      put :update, id: @corp_contact, corp_contact: {  }
      assert_redirected_to corp_contact_path(assigns(:corp_contact))
    end
  
    test "should destroy corp_contact" do
      assert_difference('CorpContact.count', -1) do
        delete :destroy, id: @corp_contact
      end
  
      assert_redirected_to corp_contacts_path
    end
  end
end
