require 'test_helper'

module Ag2Human
  class WorkerSalaryItemsControllerTest < ActionController::TestCase
    setup do
      @worker_salary_item = worker_salary_items(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:worker_salary_items)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create worker_salary_item" do
      assert_difference('WorkerSalaryItem.count') do
        post :create, worker_salary_item: {  }
      end
  
      assert_redirected_to worker_salary_item_path(assigns(:worker_salary_item))
    end
  
    test "should show worker_salary_item" do
      get :show, id: @worker_salary_item
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @worker_salary_item
      assert_response :success
    end
  
    test "should update worker_salary_item" do
      put :update, id: @worker_salary_item, worker_salary_item: {  }
      assert_redirected_to worker_salary_item_path(assigns(:worker_salary_item))
    end
  
    test "should destroy worker_salary_item" do
      assert_difference('WorkerSalaryItem.count', -1) do
        delete :destroy, id: @worker_salary_item
      end
  
      assert_redirected_to worker_salary_items_path
    end
  end
end
