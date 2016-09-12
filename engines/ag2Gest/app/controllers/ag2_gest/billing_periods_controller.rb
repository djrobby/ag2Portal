require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillingPeriodsController < ApplicationController
    # GET /billing_periods
    # GET /billing_periods.json
    def index
      @billing_periods = BillingPeriod.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billing_periods }
      end
    end
  
    # GET /billing_periods/1
    # GET /billing_periods/1.json
    def show
      @billing_period = BillingPeriod.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billing_period }
      end
    end
  
    # GET /billing_periods/new
    # GET /billing_periods/new.json
    def new
      @billing_period = BillingPeriod.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billing_period }
      end
    end
  
    # GET /billing_periods/1/edit
    def edit
      @billing_period = BillingPeriod.find(params[:id])
    end
  
    # POST /billing_periods
    # POST /billing_periods.json
    def create
      @billing_period = BillingPeriod.new(params[:billing_period])
  
      respond_to do |format|
        if @billing_period.save
          format.html { redirect_to @billing_period, notice: 'Billing period was successfully created.' }
          format.json { render json: @billing_period, status: :created, location: @billing_period }
        else
          format.html { render action: "new" }
          format.json { render json: @billing_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /billing_periods/1
    # PUT /billing_periods/1.json
    def update
      @billing_period = BillingPeriod.find(params[:id])
  
      respond_to do |format|
        if @billing_period.update_attributes(params[:billing_period])
          format.html { redirect_to @billing_period, notice: 'Billing period was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billing_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /billing_periods/1
    # DELETE /billing_periods/1.json
    def destroy
      @billing_period = BillingPeriod.find(params[:id])
      @billing_period.destroy
  
      respond_to do |format|
        format.html { redirect_to billing_periods_url }
        format.json { head :no_content }
      end
    end
  end
end
