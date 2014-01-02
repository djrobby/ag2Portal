require 'test_helper'

module Ag2Human
  class WorkerItemsControllerTest < ActionController::TestCase
    setup do
      @worker_item = worker_items(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:worker_items)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create worker_item" do
      assert_difference('WorkerItem.count') do
        post :create, worker_item: {  }
      end
  
      assert_redirected_to worker_item_path(assigns(:worker_item))
    end
  
    test "should show worker_item" do
      get :show, id: @worker_item
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @worker_item
      assert_response :success
    end
  
    test "should update worker_item" do
      put :update, id: @worker_item, worker_item: {  }
      assert_redirected_to worker_item_path(assigns(:worker_item))
    end
  
    test "should destroy worker_item" do
      assert_difference('WorkerItem.count', -1) do
        delete :destroy, id: @worker_item
      end
  
      assert_redirected_to worker_items_path
    end
  end
end
