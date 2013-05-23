require 'test_helper'

module Ag2HelpDesk
  class TicketPrioritiesControllerTest < ActionController::TestCase
    setup do
      @ticket_priority = ticket_priorities(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:ticket_priorities)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create ticket_priority" do
      assert_difference('TicketPriority.count') do
        post :create, ticket_priority: {  }
      end
  
      assert_redirected_to ticket_priority_path(assigns(:ticket_priority))
    end
  
    test "should show ticket_priority" do
      get :show, id: @ticket_priority
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @ticket_priority
      assert_response :success
    end
  
    test "should update ticket_priority" do
      put :update, id: @ticket_priority, ticket_priority: {  }
      assert_redirected_to ticket_priority_path(assigns(:ticket_priority))
    end
  
    test "should destroy ticket_priority" do
      assert_difference('TicketPriority.count', -1) do
        delete :destroy, id: @ticket_priority
      end
  
      assert_redirected_to ticket_priorities_path
    end
  end
end
