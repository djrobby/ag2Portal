require 'test_helper'

module Ag2Admin
  class BankAccountClassesControllerTest < ActionController::TestCase
    setup do
      @bank_account_class = bank_account_classes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:bank_account_classes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create bank_account_class" do
      assert_difference('BankAccountClass.count') do
        post :create, bank_account_class: {  }
      end
  
      assert_redirected_to bank_account_class_path(assigns(:bank_account_class))
    end
  
    test "should show bank_account_class" do
      get :show, id: @bank_account_class
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @bank_account_class
      assert_response :success
    end
  
    test "should update bank_account_class" do
      put :update, id: @bank_account_class, bank_account_class: {  }
      assert_redirected_to bank_account_class_path(assigns(:bank_account_class))
    end
  
    test "should destroy bank_account_class" do
      assert_difference('BankAccountClass.count', -1) do
        delete :destroy, id: @bank_account_class
      end
  
      assert_redirected_to bank_account_classes_path
    end
  end
end
