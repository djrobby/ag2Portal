require 'test_helper'

module Ag2Human
  class CollectiveAgreementsControllerTest < ActionController::TestCase
    setup do
      @collective_agreement = collective_agreements(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:collective_agreements)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create collective_agreement" do
      assert_difference('CollectiveAgreement.count') do
        post :create, collective_agreement: {  }
      end
  
      assert_redirected_to collective_agreement_path(assigns(:collective_agreement))
    end
  
    test "should show collective_agreement" do
      get :show, id: @collective_agreement
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @collective_agreement
      assert_response :success
    end
  
    test "should update collective_agreement" do
      put :update, id: @collective_agreement, collective_agreement: {  }
      assert_redirected_to collective_agreement_path(assigns(:collective_agreement))
    end
  
    test "should destroy collective_agreement" do
      assert_difference('CollectiveAgreement.count', -1) do
        delete :destroy, id: @collective_agreement
      end
  
      assert_redirected_to collective_agreements_path
    end
  end
end
