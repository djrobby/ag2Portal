require 'test_helper'

module Ag2Purchase
  class SupplierInvoicesControllerTest < ActionController::TestCase
    setup do
      @supplier_invoice = supplier_invoices(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:supplier_invoices)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create supplier_invoice" do
      assert_difference('SupplierInvoice.count') do
        post :create, supplier_invoice: {  }
      end
  
      assert_redirected_to supplier_invoice_path(assigns(:supplier_invoice))
    end
  
    test "should show supplier_invoice" do
      get :show, id: @supplier_invoice
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @supplier_invoice
      assert_response :success
    end
  
    test "should update supplier_invoice" do
      put :update, id: @supplier_invoice, supplier_invoice: {  }
      assert_redirected_to supplier_invoice_path(assigns(:supplier_invoice))
    end
  
    test "should destroy supplier_invoice" do
      assert_difference('SupplierInvoice.count', -1) do
        delete :destroy, id: @supplier_invoice
      end
  
      assert_redirected_to supplier_invoices_path
    end
  end
end
