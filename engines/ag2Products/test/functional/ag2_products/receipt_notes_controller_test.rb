require 'test_helper'

module Ag2Products
  class ReceiptNotesControllerTest < ActionController::TestCase
    setup do
      @receipt_note = receipt_notes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:receipt_notes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create receipt_note" do
      assert_difference('ReceiptNote.count') do
        post :create, receipt_note: {  }
      end
  
      assert_redirected_to receipt_note_path(assigns(:receipt_note))
    end
  
    test "should show receipt_note" do
      get :show, id: @receipt_note
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @receipt_note
      assert_response :success
    end
  
    test "should update receipt_note" do
      put :update, id: @receipt_note, receipt_note: {  }
      assert_redirected_to receipt_note_path(assigns(:receipt_note))
    end
  
    test "should destroy receipt_note" do
      assert_difference('ReceiptNote.count', -1) do
        delete :destroy, id: @receipt_note
      end
  
      assert_redirected_to receipt_notes_path
    end
  end
end
