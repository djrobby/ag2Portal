require 'test_helper'

module Ag2Gest
  class BillsToFilesControllerTest < ActionController::TestCase
    setup do
      @bills_to_file = bills_to_files(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:bills_to_files)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create bills_to_file" do
      assert_difference('BillsToFile.count') do
        post :create, bills_to_file: {  }
      end
  
      assert_redirected_to bills_to_file_path(assigns(:bills_to_file))
    end
  
    test "should show bills_to_file" do
      get :show, id: @bills_to_file
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @bills_to_file
      assert_response :success
    end
  
    test "should update bills_to_file" do
      put :update, id: @bills_to_file, bills_to_file: {  }
      assert_redirected_to bills_to_file_path(assigns(:bills_to_file))
    end
  
    test "should destroy bills_to_file" do
      assert_difference('BillsToFile.count', -1) do
        delete :destroy, id: @bills_to_file
      end
  
      assert_redirected_to bills_to_files_path
    end
  end
end
