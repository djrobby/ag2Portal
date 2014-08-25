require 'test_helper'

module Ag2Tech
  class ChargeGroupsControllerTest < ActionController::TestCase
    setup do
      @charge_group = charge_groups(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:charge_groups)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create charge_group" do
      assert_difference('ChargeGroup.count') do
        post :create, charge_group: {  }
      end
  
      assert_redirected_to charge_group_path(assigns(:charge_group))
    end
  
    test "should show charge_group" do
      get :show, id: @charge_group
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @charge_group
      assert_response :success
    end
  
    test "should update charge_group" do
      put :update, id: @charge_group, charge_group: {  }
      assert_redirected_to charge_group_path(assigns(:charge_group))
    end
  
    test "should destroy charge_group" do
      assert_difference('ChargeGroup.count', -1) do
        delete :destroy, id: @charge_group
      end
  
      assert_redirected_to charge_groups_path
    end
  end
end
