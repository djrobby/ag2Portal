require 'test_helper'

module Ag2Gest
  class RegulationTypesControllerTest < ActionController::TestCase
    setup do
      @regulation_type = regulation_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:regulation_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create regulation_type" do
      assert_difference('RegulationType.count') do
        post :create, regulation_type: {  }
      end
  
      assert_redirected_to regulation_type_path(assigns(:regulation_type))
    end
  
    test "should show regulation_type" do
      get :show, id: @regulation_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @regulation_type
      assert_response :success
    end
  
    test "should update regulation_type" do
      put :update, id: @regulation_type, regulation_type: {  }
      assert_redirected_to regulation_type_path(assigns(:regulation_type))
    end
  
    test "should destroy regulation_type" do
      assert_difference('RegulationType.count', -1) do
        delete :destroy, id: @regulation_type
      end
  
      assert_redirected_to regulation_types_path
    end
  end
end
