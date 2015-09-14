require 'test_helper'

module Ag2Admin
  class BankOfficesControllerTest < ActionController::TestCase
    setup do
      @bank_office = bank_offices(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:bank_offices)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create bank_office" do
      assert_difference('BankOffice.count') do
        post :create, bank_office: {  }
      end
  
      assert_redirected_to bank_office_path(assigns(:bank_office))
    end
  
    test "should show bank_office" do
      get :show, id: @bank_office
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @bank_office
      assert_response :success
    end
  
    test "should update bank_office" do
      put :update, id: @bank_office, bank_office: {  }
      assert_redirected_to bank_office_path(assigns(:bank_office))
    end
  
    test "should destroy bank_office" do
      assert_difference('BankOffice.count', -1) do
        delete :destroy, id: @bank_office
      end
  
      assert_redirected_to bank_offices_path
    end
  end
end
