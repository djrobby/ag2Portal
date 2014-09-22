require 'test_helper'

module Ag2Tech
  class BudgetHeadingsControllerTest < ActionController::TestCase
    setup do
      @budget_heading = budget_headings(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:budget_headings)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create budget_heading" do
      assert_difference('BudgetHeading.count') do
        post :create, budget_heading: {  }
      end
  
      assert_redirected_to budget_heading_path(assigns(:budget_heading))
    end
  
    test "should show budget_heading" do
      get :show, id: @budget_heading
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @budget_heading
      assert_response :success
    end
  
    test "should update budget_heading" do
      put :update, id: @budget_heading, budget_heading: {  }
      assert_redirected_to budget_heading_path(assigns(:budget_heading))
    end
  
    test "should destroy budget_heading" do
      assert_difference('BudgetHeading.count', -1) do
        delete :destroy, id: @budget_heading
      end
  
      assert_redirected_to budget_headings_path
    end
  end
end
