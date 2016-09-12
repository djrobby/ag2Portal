require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoiceOperationsController < ApplicationController
    # GET /invoice_operations
    # GET /invoice_operations.json
    def index
      @invoice_operations = InvoiceOperation.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoice_operations }
      end
    end
  
    # GET /invoice_operations/1
    # GET /invoice_operations/1.json
    def show
      @invoice_operation = InvoiceOperation.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice_operation }
      end
    end
  
    # GET /invoice_operations/new
    # GET /invoice_operations/new.json
    def new
      @invoice_operation = InvoiceOperation.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice_operation }
      end
    end
  
    # GET /invoice_operations/1/edit
    def edit
      @invoice_operation = InvoiceOperation.find(params[:id])
    end
  
    # POST /invoice_operations
    # POST /invoice_operations.json
    def create
      @invoice_operation = InvoiceOperation.new(params[:invoice_operation])
  
      respond_to do |format|
        if @invoice_operation.save
          format.html { redirect_to @invoice_operation, notice: 'Invoice operation was successfully created.' }
          format.json { render json: @invoice_operation, status: :created, location: @invoice_operation }
        else
          format.html { render action: "new" }
          format.json { render json: @invoice_operation.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /invoice_operations/1
    # PUT /invoice_operations/1.json
    def update
      @invoice_operation = InvoiceOperation.find(params[:id])
  
      respond_to do |format|
        if @invoice_operation.update_attributes(params[:invoice_operation])
          format.html { redirect_to @invoice_operation, notice: 'Invoice operation was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @invoice_operation.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /invoice_operations/1
    # DELETE /invoice_operations/1.json
    def destroy
      @invoice_operation = InvoiceOperation.find(params[:id])
      @invoice_operation.destroy
  
      respond_to do |format|
        format.html { redirect_to invoice_operations_url }
        format.json { head :no_content }
      end
    end
  end
end
