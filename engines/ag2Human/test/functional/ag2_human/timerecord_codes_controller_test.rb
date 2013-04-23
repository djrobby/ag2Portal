require 'test_helper'

module Ag2Human
  class TimerecordCodesControllerTest < ActionController::TestCase
    setup do
      @timerecord_code = timerecord_codes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:timerecord_codes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create timerecord_code" do
      assert_difference('TimerecordCode.count') do
        post :create, timerecord_code: {  }
      end
  
      assert_redirected_to timerecord_code_path(assigns(:timerecord_code))
    end
  
    test "should show timerecord_code" do
      get :show, id: @timerecord_code
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @timerecord_code
      assert_response :success
    end
  
    test "should update timerecord_code" do
      put :update, id: @timerecord_code, timerecord_code: {  }
      assert_redirected_to timerecord_code_path(assigns(:timerecord_code))
    end
  
    test "should destroy timerecord_code" do
      assert_difference('TimerecordCode.count', -1) do
        delete :destroy, id: @timerecord_code
      end
  
      assert_redirected_to timerecord_codes_path
    end
  end
end
