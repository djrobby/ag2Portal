require 'test_helper'

module Ag2Admin
  class AccountingGroupsControllerTest < ActionController::TestCase
    setup do
      @accounting_group = accounting_groups(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:accounting_groups)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create accounting_group" do
      assert_difference('AccountingGroup.count') do
        post :create, accounting_group: {  }
      end
  
      assert_redirected_to accounting_group_path(assigns(:accounting_group))
    end
  
    test "should show accounting_group" do
      get :show, id: @accounting_group
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @accounting_group
      assert_response :success
    end
  
    test "should update accounting_group" do
      put :update, id: @accounting_group, accounting_group: {  }
      assert_redirected_to accounting_group_path(assigns(:accounting_group))
    end
  
    test "should destroy accounting_group" do
      assert_difference('AccountingGroup.count', -1) do
        delete :destroy, id: @accounting_group
      end
  
      assert_redirected_to accounting_groups_path
    end
  end
end
