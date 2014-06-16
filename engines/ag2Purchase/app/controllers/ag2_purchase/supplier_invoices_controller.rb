require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierInvoicesController < ApplicationController
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    def index
      @supplier_invoices = SupplierInvoice.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_invoices }
      end
    end
  
    # GET /supplier_invoices/1
    # GET /supplier_invoices/1.json
    def show
      @supplier_invoice = SupplierInvoice.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/new
    # GET /supplier_invoices/new.json
    def new
      @supplier_invoice = SupplierInvoice.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/1/edit
    def edit
      @supplier_invoice = SupplierInvoice.find(params[:id])
    end
  
    # POST /supplier_invoices
    # POST /supplier_invoices.json
    def create
      @supplier_invoice = SupplierInvoice.new(params[:supplier_invoice])
  
      respond_to do |format|
        if @supplier_invoice.save
          format.html { redirect_to @supplier_invoice, notice: 'Supplier invoice was successfully created.' }
          format.json { render json: @supplier_invoice, status: :created, location: @supplier_invoice }
        else
          format.html { render action: "new" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /supplier_invoices/1
    # PUT /supplier_invoices/1.json
    def update
      @supplier_invoice = SupplierInvoice.find(params[:id])
  
      respond_to do |format|
        if @supplier_invoice.update_attributes(params[:supplier_invoice])
          format.html { redirect_to @supplier_invoice, notice: 'Supplier invoice was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /supplier_invoices/1
    # DELETE /supplier_invoices/1.json
    def destroy
      @supplier_invoice = SupplierInvoice.find(params[:id])
      @supplier_invoice.destroy
  
      respond_to do |format|
        format.html { redirect_to supplier_invoices_url }
        format.json { head :no_content }
      end
    end
  end
end
