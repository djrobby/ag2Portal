require 'test_helper'

module Ag2Purchase
  class OfferRequestsControllerTest < ActionController::TestCase
    setup do
      @offer_request = offer_requests(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:offer_requests)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create offer_request" do
      assert_difference('OfferRequest.count') do
        post :create, offer_request: {  }
      end
  
      assert_redirected_to offer_request_path(assigns(:offer_request))
    end
  
    test "should show offer_request" do
      get :show, id: @offer_request
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @offer_request
      assert_response :success
    end
  
    test "should update offer_request" do
      put :update, id: @offer_request, offer_request: {  }
      assert_redirected_to offer_request_path(assigns(:offer_request))
    end
  
    test "should destroy offer_request" do
      assert_difference('OfferRequest.count', -1) do
        delete :destroy, id: @offer_request
      end
  
      assert_redirected_to offer_requests_path
    end
  end
end
