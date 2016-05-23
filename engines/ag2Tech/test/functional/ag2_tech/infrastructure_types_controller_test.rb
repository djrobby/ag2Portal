require 'test_helper'

module Ag2Tech
  class InfrastructureTypesControllerTest < ActionController::TestCase
    setup do
      @infrastructure_type = infrastructure_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:infrastructure_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create infrastructure_type" do
      assert_difference('InfrastructureType.count') do
        post :create, infrastructure_type: {  }
      end
  
      assert_redirected_to infrastructure_type_path(assigns(:infrastructure_type))
    end
  
    test "should show infrastructure_type" do
      get :show, id: @infrastructure_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @infrastructure_type
      assert_response :success
    end
  
    test "should update infrastructure_type" do
      put :update, id: @infrastructure_type, infrastructure_type: {  }
      assert_redirected_to infrastructure_type_path(assigns(:infrastructure_type))
    end
  
    test "should destroy infrastructure_type" do
      assert_difference('InfrastructureType.count', -1) do
        delete :destroy, id: @infrastructure_type
      end
  
      assert_redirected_to infrastructure_types_path
    end
  end
end
