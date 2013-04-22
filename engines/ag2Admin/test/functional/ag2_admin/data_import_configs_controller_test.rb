require 'test_helper'

module Ag2Admin
  class DataImportConfigsControllerTest < ActionController::TestCase
    setup do
      @data_import_config = data_import_configs(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:data_import_configs)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create data_import_config" do
      assert_difference('DataImportConfig.count') do
        post :create, data_import_config: {  }
      end
  
      assert_redirected_to data_import_config_path(assigns(:data_import_config))
    end
  
    test "should show data_import_config" do
      get :show, id: @data_import_config
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @data_import_config
      assert_response :success
    end
  
    test "should update data_import_config" do
      put :update, id: @data_import_config, data_import_config: {  }
      assert_redirected_to data_import_config_path(assigns(:data_import_config))
    end
  
    test "should destroy data_import_config" do
      assert_difference('DataImportConfig.count', -1) do
        delete :destroy, id: @data_import_config
      end
  
      assert_redirected_to data_import_configs_path
    end
  end
end
