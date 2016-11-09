require 'test_helper'

module Ag2Gest
  class FormalitiesControllerTest < ActionController::TestCase
    setup do
      @formality = formalities(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:formalities)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create formality" do
      assert_difference('Formality.count') do
        post :create, formality: {  }
      end
  
      assert_redirected_to formality_path(assigns(:formality))
    end
  
    test "should show formality" do
      get :show, id: @formality
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @formality
      assert_response :success
    end
  
    test "should update formality" do
      put :update, id: @formality, formality: {  }
      assert_redirected_to formality_path(assigns(:formality))
    end
  
    test "should destroy formality" do
      assert_difference('Formality.count', -1) do
        delete :destroy, id: @formality
      end
  
      assert_redirected_to formalities_path
    end
  end
end
