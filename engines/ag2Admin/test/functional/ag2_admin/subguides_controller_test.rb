require 'test_helper'

module Ag2Admin
  class SubguidesControllerTest < ActionController::TestCase
    setup do
      @subguide = subguides(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:subguides)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create subguide" do
      assert_difference('Subguide.count') do
        post :create, subguide: {  }
      end
  
      assert_redirected_to subguide_path(assigns(:subguide))
    end
  
    test "should show subguide" do
      get :show, id: @subguide
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @subguide
      assert_response :success
    end
  
    test "should update subguide" do
      put :update, id: @subguide, subguide: {  }
      assert_redirected_to subguide_path(assigns(:subguide))
    end
  
    test "should destroy subguide" do
      assert_difference('Subguide.count', -1) do
        delete :destroy, id: @subguide
      end
  
      assert_redirected_to subguides_path
    end
  end
end
