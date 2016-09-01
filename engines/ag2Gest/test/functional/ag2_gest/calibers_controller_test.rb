require 'test_helper'

module Ag2Gest
  class CalibersControllerTest < ActionController::TestCase
    setup do
      @caliber = calibers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:calibers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create caliber" do
      assert_difference('Caliber.count') do
        post :create, caliber: {  }
      end
  
      assert_redirected_to caliber_path(assigns(:caliber))
    end
  
    test "should show caliber" do
      get :show, id: @caliber
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @caliber
      assert_response :success
    end
  
    test "should update caliber" do
      put :update, id: @caliber, caliber: {  }
      assert_redirected_to caliber_path(assigns(:caliber))
    end
  
    test "should destroy caliber" do
      assert_difference('Caliber.count', -1) do
        delete :destroy, id: @caliber
      end
  
      assert_redirected_to calibers_path
    end
  end
end
