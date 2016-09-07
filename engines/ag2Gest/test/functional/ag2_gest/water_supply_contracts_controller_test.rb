require 'test_helper'

module Ag2Gest
  class WaterSupplyContractsControllerTest < ActionController::TestCase
    setup do
      @water_supply_contract = water_supply_contracts(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:water_supply_contracts)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create water_supply_contract" do
      assert_difference('WaterSupplyContract.count') do
        post :create, water_supply_contract: {  }
      end
  
      assert_redirected_to water_supply_contract_path(assigns(:water_supply_contract))
    end
  
    test "should show water_supply_contract" do
      get :show, id: @water_supply_contract
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @water_supply_contract
      assert_response :success
    end
  
    test "should update water_supply_contract" do
      put :update, id: @water_supply_contract, water_supply_contract: {  }
      assert_redirected_to water_supply_contract_path(assigns(:water_supply_contract))
    end
  
    test "should destroy water_supply_contract" do
      assert_difference('WaterSupplyContract.count', -1) do
        delete :destroy, id: @water_supply_contract
      end
  
      assert_redirected_to water_supply_contracts_path
    end
  end
end
