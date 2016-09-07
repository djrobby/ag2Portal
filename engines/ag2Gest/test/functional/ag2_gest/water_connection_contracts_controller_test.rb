require 'test_helper'

module Ag2Gest
  class WaterConnectionContractsControllerTest < ActionController::TestCase
    setup do
      @water_connection_contract = water_connection_contracts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:water_connection_contracts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create water_connection_contract" do
      assert_difference('WaterConnectionContract.count') do
        post :create, water_connection_contract: {  }
      end
  
      assert_redirected_to water_connection_contract_path(assigns(:water_connection_contract))
    end
  
    test "should show water_connection_contract" do
      get :show, id: @water_connection_contract
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @water_connection_contract
      assert_response :success
    end
  
    test "should update water_connection_contract" do
      put :update, id: @water_connection_contract, water_connection_contract: {  }
      assert_redirected_to water_connection_contract_path(assigns(:water_connection_contract))
    end
  
    test "should destroy water_connection_contract" do
      assert_difference('WaterConnectionContract.count', -1) do
        delete :destroy, id: @water_connection_contract
      end
  
      assert_redirected_to water_connection_contracts_path
    end
  end
end
