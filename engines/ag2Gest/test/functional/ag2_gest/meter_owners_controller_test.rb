require 'test_helper'

module Ag2Gest
  class MeterOwnersControllerTest < ActionController::TestCase
    setup do
      @meter_owner = meter_owners(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:meter_owners)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create meter_owner" do
      assert_difference('MeterOwner.count') do
        post :create, meter_owner: {  }
      end
  
      assert_redirected_to meter_owner_path(assigns(:meter_owner))
    end
  
    test "should show meter_owner" do
      get :show, id: @meter_owner
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @meter_owner
      assert_response :success
    end
  
    test "should update meter_owner" do
      put :update, id: @meter_owner, meter_owner: {  }
      assert_redirected_to meter_owner_path(assigns(:meter_owner))
    end
  
    test "should destroy meter_owner" do
      assert_difference('MeterOwner.count', -1) do
        delete :destroy, id: @meter_owner
      end
  
      assert_redirected_to meter_owners_path
    end
  end
end
