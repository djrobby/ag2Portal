require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ClientPaymentsController < ApplicationController
    # GET /client_payments
    # GET /client_payments.json
    def index
      @client_payments = ClientPayment.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @client_payments }
      end
    end
  
    # GET /client_payments/1
    # GET /client_payments/1.json
    def show
      @client_payment = ClientPayment.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @client_payment }
      end
    end
  
    # GET /client_payments/new
    # GET /client_payments/new.json
    def new
      @client_payment = ClientPayment.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @client_payment }
      end
    end
  
    # GET /client_payments/1/edit
    def edit
      @client_payment = ClientPayment.find(params[:id])
    end
  
    # POST /client_payments
    # POST /client_payments.json
    def create
      @client_payment = ClientPayment.new(params[:client_payment])
  
      respond_to do |format|
        if @client_payment.save
          format.html { redirect_to @client_payment, notice: 'Client payment was successfully created.' }
          format.json { render json: @client_payment, status: :created, location: @client_payment }
        else
          format.html { render action: "new" }
          format.json { render json: @client_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /client_payments/1
    # PUT /client_payments/1.json
    def update
      @client_payment = ClientPayment.find(params[:id])
  
      respond_to do |format|
        if @client_payment.update_attributes(params[:client_payment])
          format.html { redirect_to @client_payment, notice: 'Client payment was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @client_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /client_payments/1
    # DELETE /client_payments/1.json
    def destroy
      @client_payment = ClientPayment.find(params[:id])
      @client_payment.destroy
  
      respond_to do |format|
        format.html { redirect_to client_payments_url }
        format.json { head :no_content }
      end
    end
  end
end
