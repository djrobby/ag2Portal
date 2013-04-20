require 'test_helper'

module Ag2Directory
  class SharedContactTypesControllerTest < ActionController::TestCase
    setup do
      @shared_contact_type = shared_contact_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:shared_contact_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create shared_contact_type" do
      assert_difference('SharedContactType.count') do
        post :create, shared_contact_type: {  }
      end
  
      assert_redirected_to shared_contact_type_path(assigns(:shared_contact_type))
    end
  
    test "should show shared_contact_type" do
      get :show, id: @shared_contact_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @shared_contact_type
      assert_response :success
    end
  
    test "should update shared_contact_type" do
      put :update, id: @shared_contact_type, shared_contact_type: {  }
      assert_redirected_to shared_contact_type_path(assigns(:shared_contact_type))
    end
  
    test "should destroy shared_contact_type" do
      assert_difference('SharedContactType.count', -1) do
        delete :destroy, id: @shared_contact_type
      end
  
      assert_redirected_to shared_contact_types_path
    end
  end
end
