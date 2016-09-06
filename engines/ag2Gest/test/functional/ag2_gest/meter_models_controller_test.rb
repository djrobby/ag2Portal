require 'test_helper'

module Ag2Gest
  class MeterModelsControllerTest < ActionController::TestCase
    setup do
      @meter_model = meter_models(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:meter_models)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create meter_model" do
      assert_difference('MeterModel.count') do
        post :create, meter_model: {  }
      end
  
      assert_redirected_to meter_model_path(assigns(:meter_model))
    end
  
    test "should show meter_model" do
      get :show, id: @meter_model
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @meter_model
      assert_response :success
    end
  
    test "should update meter_model" do
      put :update, id: @meter_model, meter_model: {  }
      assert_redirected_to meter_model_path(assigns(:meter_model))
    end
  
    test "should destroy meter_model" do
      assert_difference('MeterModel.count', -1) do
        delete :destroy, id: @meter_model
      end
  
      assert_redirected_to meter_models_path
    end
  end
end
