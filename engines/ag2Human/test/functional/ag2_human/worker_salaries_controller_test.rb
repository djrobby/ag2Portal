require 'test_helper'

module Ag2Human
  class WorkerSalariesControllerTest < ActionController::TestCase
    setup do
      @worker_salary = worker_salaries(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:worker_salaries)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create worker_salary" do
      assert_difference('WorkerSalary.count') do
        post :create, worker_salary: {  }
      end
  
      assert_redirected_to worker_salary_path(assigns(:worker_salary))
    end
  
    test "should show worker_salary" do
      get :show, id: @worker_salary
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @worker_salary
      assert_response :success
    end
  
    test "should update worker_salary" do
      put :update, id: @worker_salary, worker_salary: {  }
      assert_redirected_to worker_salary_path(assigns(:worker_salary))
    end
  
    test "should destroy worker_salary" do
      assert_difference('WorkerSalary.count', -1) do
        delete :destroy, id: @worker_salary
      end
  
      assert_redirected_to worker_salaries_path
    end
  end
end
