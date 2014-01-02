require 'test_helper'

module Ag2Human
  class SalaryConceptsControllerTest < ActionController::TestCase
    setup do
      @salary_concept = salary_concepts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:salary_concepts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create salary_concept" do
      assert_difference('SalaryConcept.count') do
        post :create, salary_concept: {  }
      end
  
      assert_redirected_to salary_concept_path(assigns(:salary_concept))
    end
  
    test "should show salary_concept" do
      get :show, id: @salary_concept
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @salary_concept
      assert_response :success
    end
  
    test "should update salary_concept" do
      put :update, id: @salary_concept, salary_concept: {  }
      assert_redirected_to salary_concept_path(assigns(:salary_concept))
    end
  
    test "should destroy salary_concept" do
      assert_difference('SalaryConcept.count', -1) do
        delete :destroy, id: @salary_concept
      end
  
      assert_redirected_to salary_concepts_path
    end
  end
end
