require 'test_helper'

module Ag2Gest
  class ComplaintClassesControllerTest < ActionController::TestCase
    setup do
      @complaint_class = complaint_classes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:complaint_classes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create complaint_class" do
      assert_difference('ComplaintClass.count') do
        post :create, complaint_class: {  }
      end
  
      assert_redirected_to complaint_class_path(assigns(:complaint_class))
    end
  
    test "should show complaint_class" do
      get :show, id: @complaint_class
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @complaint_class
      assert_response :success
    end
  
    test "should update complaint_class" do
      put :update, id: @complaint_class, complaint_class: {  }
      assert_redirected_to complaint_class_path(assigns(:complaint_class))
    end
  
    test "should destroy complaint_class" do
      assert_difference('ComplaintClass.count', -1) do
        delete :destroy, id: @complaint_class
      end
  
      assert_redirected_to complaint_classes_path
    end
  end
end
