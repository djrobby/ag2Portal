require 'test_helper'

module Ag2Gest
  class ReadingIncidenceTypesControllerTest < ActionController::TestCase
    setup do
      @reading_incidence_type = reading_incidence_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:reading_incidence_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create reading_incidence_type" do
      assert_difference('ReadingIncidenceType.count') do
        post :create, reading_incidence_type: {  }
      end
  
      assert_redirected_to reading_incidence_type_path(assigns(:reading_incidence_type))
    end
  
    test "should show reading_incidence_type" do
      get :show, id: @reading_incidence_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @reading_incidence_type
      assert_response :success
    end
  
    test "should update reading_incidence_type" do
      put :update, id: @reading_incidence_type, reading_incidence_type: {  }
      assert_redirected_to reading_incidence_type_path(assigns(:reading_incidence_type))
    end
  
    test "should destroy reading_incidence_type" do
      assert_difference('ReadingIncidenceType.count', -1) do
        delete :destroy, id: @reading_incidence_type
      end
  
      assert_redirected_to reading_incidence_types_path
    end
  end
end
