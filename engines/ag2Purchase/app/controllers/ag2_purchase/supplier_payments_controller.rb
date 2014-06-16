require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierPaymentsController < ApplicationController
    # GET /supplier_payments
    # GET /supplier_payments.json
    def index
      @supplier_payments = SupplierPayment.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_payments }
      end
    end
  
    # GET /supplier_payments/1
    # GET /supplier_payments/1.json
    def show
      @supplier_payment = SupplierPayment.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_payment }
      end
    end
  
    # GET /supplier_payments/new
    # GET /supplier_payments/new.json
    def new
      @supplier_payment = SupplierPayment.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_payment }
      end
    end
  
    # GET /supplier_payments/1/edit
    def edit
      @supplier_payment = SupplierPayment.find(params[:id])
    end
  
    # POST /supplier_payments
    # POST /supplier_payments.json
    def create
      @supplier_payment = SupplierPayment.new(params[:supplier_payment])
  
      respond_to do |format|
        if @supplier_payment.save
          format.html { redirect_to @supplier_payment, notice: 'Supplier payment was successfully created.' }
          format.json { render json: @supplier_payment, status: :created, location: @supplier_payment }
        else
          format.html { render action: "new" }
          format.json { render json: @supplier_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /supplier_payments/1
    # PUT /supplier_payments/1.json
    def update
      @supplier_payment = SupplierPayment.find(params[:id])
  
      respond_to do |format|
        if @supplier_payment.update_attributes(params[:supplier_payment])
          format.html { redirect_to @supplier_payment, notice: 'Supplier payment was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @supplier_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /supplier_payments/1
    # DELETE /supplier_payments/1.json
    def destroy
      @supplier_payment = SupplierPayment.find(params[:id])
      @supplier_payment.destroy
  
      respond_to do |format|
        format.html { redirect_to supplier_payments_url }
        format.json { head :no_content }
      end
    end
  end
end
