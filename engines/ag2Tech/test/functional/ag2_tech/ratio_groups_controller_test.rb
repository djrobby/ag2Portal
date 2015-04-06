require 'test_helper'

module Ag2Tech
  class RatioGroupsControllerTest < ActionController::TestCase
    setup do
      @ratio_group = ratio_groups(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:ratio_groups)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create ratio_group" do
      assert_difference('RatioGroup.count') do
        post :create, ratio_group: {  }
      end
  
      assert_redirected_to ratio_group_path(assigns(:ratio_group))
    end
  
    test "should show ratio_group" do
      get :show, id: @ratio_group
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @ratio_group
      assert_response :success
    end
  
    test "should update ratio_group" do
      put :update, id: @ratio_group, ratio_group: {  }
      assert_redirected_to ratio_group_path(assigns(:ratio_group))
    end
  
    test "should destroy ratio_group" do
      assert_difference('RatioGroup.count', -1) do
        delete :destroy, id: @ratio_group
      end
  
      assert_redirected_to ratio_groups_path
    end
  end
end
