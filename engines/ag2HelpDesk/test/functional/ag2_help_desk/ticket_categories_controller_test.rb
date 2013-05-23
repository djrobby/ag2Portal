require 'test_helper'

module Ag2HelpDesk
  class TicketCategoriesControllerTest < ActionController::TestCase
    setup do
      @ticket_category = ticket_categories(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:ticket_categories)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create ticket_category" do
      assert_difference('TicketCategory.count') do
        post :create, ticket_category: {  }
      end
  
      assert_redirected_to ticket_category_path(assigns(:ticket_category))
    end
  
    test "should show ticket_category" do
      get :show, id: @ticket_category
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @ticket_category
      assert_response :success
    end
  
    test "should update ticket_category" do
      put :update, id: @ticket_category, ticket_category: {  }
      assert_redirected_to ticket_category_path(assigns(:ticket_category))
    end
  
    test "should destroy ticket_category" do
      assert_difference('TicketCategory.count', -1) do
        delete :destroy, id: @ticket_category
      end
  
      assert_redirected_to ticket_categories_path
    end
  end
end
