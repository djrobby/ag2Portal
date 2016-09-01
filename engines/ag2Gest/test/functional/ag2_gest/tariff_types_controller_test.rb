require 'test_helper'

module Ag2Gest
  class TariffTypesControllerTest < ActionController::TestCase
    setup do
      @tariff_type = tariff_types(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:tariff_types)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create tariff_type" do
      assert_difference('TariffType.count') do
        post :create, tariff_type: {  }
      end
  
      assert_redirected_to tariff_type_path(assigns(:tariff_type))
    end
  
    test "should show tariff_type" do
      get :show, id: @tariff_type
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @tariff_type
      assert_response :success
    end
  
    test "should update tariff_type" do
      put :update, id: @tariff_type, tariff_type: {  }
      assert_redirected_to tariff_type_path(assigns(:tariff_type))
    end
  
    test "should destroy tariff_type" do
      assert_difference('TariffType.count', -1) do
        delete :destroy, id: @tariff_type
      end
  
      assert_redirected_to tariff_types_path
    end
  end
end
