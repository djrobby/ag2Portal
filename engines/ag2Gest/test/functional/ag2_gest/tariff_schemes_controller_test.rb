require 'test_helper'

module Ag2Gest
  class TariffSchemesControllerTest < ActionController::TestCase
    setup do
      @tariff_scheme = tariff_schemes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:tariff_schemes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create tariff_scheme" do
      assert_difference('TariffScheme.count') do
        post :create, tariff_scheme: {  }
      end
  
      assert_redirected_to tariff_scheme_path(assigns(:tariff_scheme))
    end
  
    test "should show tariff_scheme" do
      get :show, id: @tariff_scheme
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @tariff_scheme
      assert_response :success
    end
  
    test "should update tariff_scheme" do
      put :update, id: @tariff_scheme, tariff_scheme: {  }
      assert_redirected_to tariff_scheme_path(assigns(:tariff_scheme))
    end
  
    test "should destroy tariff_scheme" do
      assert_difference('TariffScheme.count', -1) do
        delete :destroy, id: @tariff_scheme
      end
  
      assert_redirected_to tariff_schemes_path
    end
  end
end
