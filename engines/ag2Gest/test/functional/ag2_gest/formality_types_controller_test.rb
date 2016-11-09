require 'test_helper'

module Ag2Gest
  class FormalityTypesControllerTest < ActionController::TestCase
    setup do
      @formality_type = formality_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:formality_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create formality_type" do
      assert_difference('FormalityType.count') do
        post :create, formality_type: {  }
      end
  
      assert_redirected_to formality_type_path(assigns(:formality_type))
    end
  
    test "should show formality_type" do
      get :show, id: @formality_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @formality_type
      assert_response :success
    end
  
    test "should update formality_type" do
      put :update, id: @formality_type, formality_type: {  }
      assert_redirected_to formality_type_path(assigns(:formality_type))
    end
  
    test "should destroy formality_type" do
      assert_difference('FormalityType.count', -1) do
        delete :destroy, id: @formality_type
      end
  
      assert_redirected_to formality_types_path
    end
  end
end
