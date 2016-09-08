require 'test_helper'

module Ag2Gest
  class StreetDirectoriesControllerTest < ActionController::TestCase
    setup do
      @street_directory = street_directories(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:street_directories)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create street_directory" do
      assert_difference('StreetDirectory.count') do
        post :create, street_directory: {  }
      end
  
      assert_redirected_to street_directory_path(assigns(:street_directory))
    end
  
    test "should show street_directory" do
      get :show, id: @street_directory
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @street_directory
      assert_response :success
    end
  
    test "should update street_directory" do
      put :update, id: @street_directory, street_directory: {  }
      assert_redirected_to street_directory_path(assigns(:street_directory))
    end
  
    test "should destroy street_directory" do
      assert_difference('StreetDirectory.count', -1) do
        delete :destroy, id: @street_directory
      end
  
      assert_redirected_to street_directories_path
    end
  end
end
