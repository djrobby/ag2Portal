require 'test_helper'

module Ag2Tech
  class InfrastructuresControllerTest < ActionController::TestCase
    setup do
      @infrastructure = infrastructures(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:infrastructures)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create infrastructure" do
      assert_difference('Infrastructure.count') do
        post :create, infrastructure: {  }
      end
  
      assert_redirected_to infrastructure_path(assigns(:infrastructure))
    end
  
    test "should show infrastructure" do
      get :show, id: @infrastructure
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @infrastructure
      assert_response :success
    end
  
    test "should update infrastructure" do
      put :update, id: @infrastructure, infrastructure: {  }
      assert_redirected_to infrastructure_path(assigns(:infrastructure))
    end
  
    test "should destroy infrastructure" do
      assert_difference('Infrastructure.count', -1) do
        delete :destroy, id: @infrastructure
      end
  
      assert_redirected_to infrastructures_path
    end
  end
end
