require 'test_helper'

module Ag2Gest
  class BillableConceptsControllerTest < ActionController::TestCase
    setup do
      @billable_concept = billable_concepts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:billable_concepts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create billable_concept" do
      assert_difference('BillableConcept.count') do
        post :create, billable_concept: {  }
      end
  
      assert_redirected_to billable_concept_path(assigns(:billable_concept))
    end
  
    test "should show billable_concept" do
      get :show, id: @billable_concept
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @billable_concept
      assert_response :success
    end
  
    test "should update billable_concept" do
      put :update, id: @billable_concept, billable_concept: {  }
      assert_redirected_to billable_concept_path(assigns(:billable_concept))
    end
  
    test "should destroy billable_concept" do
      assert_difference('BillableConcept.count', -1) do
        delete :destroy, id: @billable_concept
      end
  
      assert_redirected_to billable_concepts_path
    end
  end
end
