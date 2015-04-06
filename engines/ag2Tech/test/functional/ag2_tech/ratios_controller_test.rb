require 'test_helper'

module Ag2Tech
  class RatiosControllerTest < ActionController::TestCase
    setup do
      @ratio = ratios(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:ratios)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create ratio" do
      assert_difference('Ratio.count') do
        post :create, ratio: {  }
      end
  
      assert_redirected_to ratio_path(assigns(:ratio))
    end
  
    test "should show ratio" do
      get :show, id: @ratio
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @ratio
      assert_response :success
    end
  
    test "should update ratio" do
      put :update, id: @ratio, ratio: {  }
      assert_redirected_to ratio_path(assigns(:ratio))
    end
  
    test "should destroy ratio" do
      assert_difference('Ratio.count', -1) do
        delete :destroy, id: @ratio
      end
  
      assert_redirected_to ratios_path
    end
  end
end
