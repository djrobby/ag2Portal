require 'test_helper'

module Ag2Gest
  class MeterBrandsControllerTest < ActionController::TestCase
    setup do
      @meter_brand = meter_brands(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:meter_brands)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create meter_brand" do
      assert_difference('MeterBrand.count') do
        post :create, meter_brand: {  }
      end
  
      assert_redirected_to meter_brand_path(assigns(:meter_brand))
    end
  
    test "should show meter_brand" do
      get :show, id: @meter_brand
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @meter_brand
      assert_response :success
    end
  
    test "should update meter_brand" do
      put :update, id: @meter_brand, meter_brand: {  }
      assert_redirected_to meter_brand_path(assigns(:meter_brand))
    end
  
    test "should destroy meter_brand" do
      assert_difference('MeterBrand.count', -1) do
        delete :destroy, id: @meter_brand
      end
  
      assert_redirected_to meter_brands_path
    end
  end
end
