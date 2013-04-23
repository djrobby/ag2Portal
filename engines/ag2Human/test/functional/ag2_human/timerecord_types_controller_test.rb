require 'test_helper'

module Ag2Human
  class TimerecordTypesControllerTest < ActionController::TestCase
    setup do
      @timerecord_type = timerecord_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:timerecord_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create timerecord_type" do
      assert_difference('TimerecordType.count') do
        post :create, timerecord_type: {  }
      end
  
      assert_redirected_to timerecord_type_path(assigns(:timerecord_type))
    end
  
    test "should show timerecord_type" do
      get :show, id: @timerecord_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @timerecord_type
      assert_response :success
    end
  
    test "should update timerecord_type" do
      put :update, id: @timerecord_type, timerecord_type: {  }
      assert_redirected_to timerecord_type_path(assigns(:timerecord_type))
    end
  
    test "should destroy timerecord_type" do
      assert_difference('TimerecordType.count', -1) do
        delete :destroy, id: @timerecord_type
      end
  
      assert_redirected_to timerecord_types_path
    end
  end
end
