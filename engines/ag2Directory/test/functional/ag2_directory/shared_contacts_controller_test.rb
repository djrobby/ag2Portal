require 'test_helper'

module Ag2Directory
  class SharedContactsControllerTest < ActionController::TestCase
    setup do
      @shared_contact = shared_contacts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:shared_contacts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create shared_contact" do
      assert_difference('SharedContact.count') do
        post :create, shared_contact: {  }
      end
  
      assert_redirected_to shared_contact_path(assigns(:shared_contact))
    end
  
    test "should show shared_contact" do
      get :show, id: @shared_contact
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @shared_contact
      assert_response :success
    end
  
    test "should update shared_contact" do
      put :update, id: @shared_contact, shared_contact: {  }
      assert_redirected_to shared_contact_path(assigns(:shared_contact))
    end
  
    test "should destroy shared_contact" do
      assert_difference('SharedContact.count', -1) do
        delete :destroy, id: @shared_contact
      end
  
      assert_redirected_to shared_contacts_path
    end
  end
end
