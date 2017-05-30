require 'test_helper'

module Ag2Admin
  class CurrencyInstrumentsControllerTest < ActionController::TestCase
    setup do
      @currency_instrument = currency_instruments(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:currency_instruments)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create currency_instrument" do
      assert_difference('CurrencyInstrument.count') do
        post :create, currency_instrument: {  }
      end
  
      assert_redirected_to currency_instrument_path(assigns(:currency_instrument))
    end
  
    test "should show currency_instrument" do
      get :show, id: @currency_instrument
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @currency_instrument
      assert_response :success
    end
  
    test "should update currency_instrument" do
      put :update, id: @currency_instrument, currency_instrument: {  }
      assert_redirected_to currency_instrument_path(assigns(:currency_instrument))
    end
  
    test "should destroy currency_instrument" do
      assert_difference('CurrencyInstrument.count', -1) do
        delete :destroy, id: @currency_instrument
      end
  
      assert_redirected_to currency_instruments_path
    end
  end
end
