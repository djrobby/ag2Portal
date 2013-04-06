require 'test_helper'

module Ag2Human
  class ProfessionalGroupsControllerTest < ActionController::TestCase
    setup do
      @professional_group = professional_groups(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:professional_groups)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create professional_group" do
      assert_difference('ProfessionalGroup.count') do
        post :create, professional_group: {  }
      end
  
      assert_redirected_to professional_group_path(assigns(:professional_group))
    end
  
    test "should show professional_group" do
      get :show, id: @professional_group
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @professional_group
      assert_response :success
    end
  
    test "should update professional_group" do
      put :update, id: @professional_group, professional_group: {  }
      assert_redirected_to professional_group_path(assigns(:professional_group))
    end
  
    test "should destroy professional_group" do
      assert_difference('ProfessionalGroup.count', -1) do
        delete :destroy, id: @professional_group
      end
  
      assert_redirected_to professional_groups_path
    end
  end
end
