require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillingFrequenciesController < ApplicationController
    # GET /billing_frequencies
    # GET /billing_frequencies.json
    def index
      @billing_frequencies = BillingFrequency.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billing_frequencies }
      end
    end
  
    # GET /billing_frequencies/1
    # GET /billing_frequencies/1.json
    def show
      @billing_frequency = BillingFrequency.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billing_frequency }
      end
    end
  
    # GET /billing_frequencies/new
    # GET /billing_frequencies/new.json
    def new
      @billing_frequency = BillingFrequency.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billing_frequency }
      end
    end
  
    # GET /billing_frequencies/1/edit
    def edit
      @billing_frequency = BillingFrequency.find(params[:id])
    end
  
    # POST /billing_frequencies
    # POST /billing_frequencies.json
    def create
      @billing_frequency = BillingFrequency.new(params[:billing_frequency])
  
      respond_to do |format|
        if @billing_frequency.save
          format.html { redirect_to @billing_frequency, notice: 'Billing frequency was successfully created.' }
          format.json { render json: @billing_frequency, status: :created, location: @billing_frequency }
        else
          format.html { render action: "new" }
          format.json { render json: @billing_frequency.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /billing_frequencies/1
    # PUT /billing_frequencies/1.json
    def update
      @billing_frequency = BillingFrequency.find(params[:id])
  
      respond_to do |format|
        if @billing_frequency.update_attributes(params[:billing_frequency])
          format.html { redirect_to @billing_frequency, notice: 'Billing frequency was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billing_frequency.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /billing_frequencies/1
    # DELETE /billing_frequencies/1.json
    def destroy
      @billing_frequency = BillingFrequency.find(params[:id])
      @billing_frequency.destroy
  
      respond_to do |format|
        format.html { redirect_to billing_frequencies_url }
        format.json { head :no_content }
      end
    end
  end
end
