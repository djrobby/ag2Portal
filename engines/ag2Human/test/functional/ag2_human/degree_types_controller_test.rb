require 'test_helper'

module Ag2Human
  class DegreeTypesControllerTest < ActionController::TestCase
    setup do
      @degree_type = degree_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:degree_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create degree_type" do
      assert_difference('DegreeType.count') do
        post :create, degree_type: {  }
      end
  
      assert_redirected_to degree_type_path(assigns(:degree_type))
    end
  
    test "should show degree_type" do
      get :show, id: @degree_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @degree_type
      assert_response :success
    end
  
    test "should update degree_type" do
      put :update, id: @degree_type, degree_type: {  }
      assert_redirected_to degree_type_path(assigns(:degree_type))
    end
  
    test "should destroy degree_type" do
      assert_difference('DegreeType.count', -1) do
        delete :destroy, id: @degree_type
      end
  
      assert_redirected_to degree_types_path
    end
  end
end
