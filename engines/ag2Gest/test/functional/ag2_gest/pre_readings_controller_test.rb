require 'test_helper'

module Ag2Gest
  class PreReadingsControllerTest < ActionController::TestCase
    setup do
      @pre_reading = pre_readings(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:pre_readings)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create pre_reading" do
      assert_difference('PreReading.count') do
        post :create, pre_reading: {  }
      end
  
      assert_redirected_to pre_reading_path(assigns(:pre_reading))
    end
  
    test "should show pre_reading" do
      get :show, id: @pre_reading
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @pre_reading
      assert_response :success
    end
  
    test "should update pre_reading" do
      put :update, id: @pre_reading, pre_reading: {  }
      assert_redirected_to pre_reading_path(assigns(:pre_reading))
    end
  
    test "should destroy pre_reading" do
      assert_difference('PreReading.count', -1) do
        delete :destroy, id: @pre_reading
      end
  
      assert_redirected_to pre_readings_path
    end
  end
end
