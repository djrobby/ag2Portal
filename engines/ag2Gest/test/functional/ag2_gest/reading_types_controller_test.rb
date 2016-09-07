require 'test_helper'

module Ag2Gest
  class ReadingTypesControllerTest < ActionController::TestCase
    setup do
      @reading_type = reading_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:reading_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create reading_type" do
      assert_difference('ReadingType.count') do
        post :create, reading_type: {  }
      end
  
      assert_redirected_to reading_type_path(assigns(:reading_type))
    end
  
    test "should show reading_type" do
      get :show, id: @reading_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @reading_type
      assert_response :success
    end
  
    test "should update reading_type" do
      put :update, id: @reading_type, reading_type: {  }
      assert_redirected_to reading_type_path(assigns(:reading_type))
    end
  
    test "should destroy reading_type" do
      assert_difference('ReadingType.count', -1) do
        delete :destroy, id: @reading_type
      end
  
      assert_redirected_to reading_types_path
    end
  end
end
