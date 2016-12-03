require 'test_helper'

module Ag2Gest
  class SubscriberAnnotationClassesControllerTest < ActionController::TestCase
    setup do
      @subscriber_annotation_class = subscriber_annotation_classes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:subscriber_annotation_classes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create subscriber_annotation_class" do
      assert_difference('SubscriberAnnotationClass.count') do
        post :create, subscriber_annotation_class: {  }
      end
  
      assert_redirected_to subscriber_annotation_class_path(assigns(:subscriber_annotation_class))
    end
  
    test "should show subscriber_annotation_class" do
      get :show, id: @subscriber_annotation_class
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @subscriber_annotation_class
      assert_response :success
    end
  
    test "should update subscriber_annotation_class" do
      put :update, id: @subscriber_annotation_class, subscriber_annotation_class: {  }
      assert_redirected_to subscriber_annotation_class_path(assigns(:subscriber_annotation_class))
    end
  
    test "should destroy subscriber_annotation_class" do
      assert_difference('SubscriberAnnotationClass.count', -1) do
        delete :destroy, id: @subscriber_annotation_class
      end
  
      assert_redirected_to subscriber_annotation_classes_path
    end
  end
end
