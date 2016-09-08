require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SaleOfferStatusesController < ApplicationController
    # GET /sale_offer_statuses
    # GET /sale_offer_statuses.json
    def index
      @sale_offer_statuses = SaleOfferStatus.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sale_offer_statuses }
      end
    end
  
    # GET /sale_offer_statuses/1
    # GET /sale_offer_statuses/1.json
    def show
      @sale_offer_status = SaleOfferStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sale_offer_status }
      end
    end
  
    # GET /sale_offer_statuses/new
    # GET /sale_offer_statuses/new.json
    def new
      @sale_offer_status = SaleOfferStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer_status }
      end
    end
  
    # GET /sale_offer_statuses/1/edit
    def edit
      @sale_offer_status = SaleOfferStatus.find(params[:id])
    end
  
    # POST /sale_offer_statuses
    # POST /sale_offer_statuses.json
    def create
      @sale_offer_status = SaleOfferStatus.new(params[:sale_offer_status])
  
      respond_to do |format|
        if @sale_offer_status.save
          format.html { redirect_to @sale_offer_status, notice: 'Sale offer status was successfully created.' }
          format.json { render json: @sale_offer_status, status: :created, location: @sale_offer_status }
        else
          format.html { render action: "new" }
          format.json { render json: @sale_offer_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sale_offer_statuses/1
    # PUT /sale_offer_statuses/1.json
    def update
      @sale_offer_status = SaleOfferStatus.find(params[:id])
  
      respond_to do |format|
        if @sale_offer_status.update_attributes(params[:sale_offer_status])
          format.html { redirect_to @sale_offer_status, notice: 'Sale offer status was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sale_offer_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sale_offer_statuses/1
    # DELETE /sale_offer_statuses/1.json
    def destroy
      @sale_offer_status = SaleOfferStatus.find(params[:id])
      @sale_offer_status.destroy
  
      respond_to do |format|
        format.html { redirect_to sale_offer_statuses_url }
        format.json { head :no_content }
      end
    end
  end
end
