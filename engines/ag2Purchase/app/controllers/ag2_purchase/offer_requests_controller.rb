require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OfferRequestsController < ApplicationController
    # GET /offer_requests
    # GET /offer_requests.json
    def index
      @offer_requests = OfferRequest.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offer_requests }
      end
    end
  
    # GET /offer_requests/1
    # GET /offer_requests/1.json
    def show
      @offer_request = OfferRequest.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/new
    # GET /offer_requests/new.json
    def new
      @offer_request = OfferRequest.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/1/edit
    def edit
      @offer_request = OfferRequest.find(params[:id])
    end
  
    # POST /offer_requests
    # POST /offer_requests.json
    def create
      @offer_request = OfferRequest.new(params[:offer_request])
  
      respond_to do |format|
        if @offer_request.save
          format.html { redirect_to @offer_request, notice: 'Offer request was successfully created.' }
          format.json { render json: @offer_request, status: :created, location: @offer_request }
        else
          format.html { render action: "new" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /offer_requests/1
    # PUT /offer_requests/1.json
    def update
      @offer_request = OfferRequest.find(params[:id])
  
      respond_to do |format|
        if @offer_request.update_attributes(params[:offer_request])
          format.html { redirect_to @offer_request, notice: 'Offer request was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /offer_requests/1
    # DELETE /offer_requests/1.json
    def destroy
      @offer_request = OfferRequest.find(params[:id])
      @offer_request.destroy
  
      respond_to do |format|
        format.html { redirect_to offer_requests_url }
        format.json { head :no_content }
      end
    end
  end
end
