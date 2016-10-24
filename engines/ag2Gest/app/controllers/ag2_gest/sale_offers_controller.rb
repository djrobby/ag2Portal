require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SaleOffersController < ApplicationController
    
    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column



    # GET /sale_offers
    # GET /sale_offers.json
    def index
      @sale_offers = SaleOffer.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sale_offers }
      end
    end
  
    # GET /sale_offers/1
    # GET /sale_offers/1.json
    def show
      @sale_offer = SaleOffer.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sale_offer }
      end
    end
  
    # GET /sale_offers/new
    # GET /sale_offers/new.json
    def new
      @sale_offer = SaleOffer.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer }
      end
    end
  
    # GET /sale_offers/1/edit
    def edit
      @sale_offer = SaleOffer.find(params[:id])
    end
  
    # POST /sale_offers
    # POST /sale_offers.json
    def create
      @sale_offer = SaleOffer.new(params[:sale_offer])
  
      respond_to do |format|
        if @sale_offer.save
          format.html { redirect_to @sale_offer, notice: t('activerecord.attributes.sale_offer.create') }
          format.json { render json: @sale_offer, status: :created, location: @sale_offer }
        else
          format.html { render action: "new" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sale_offers/1
    # PUT /sale_offers/1.json
    def update
      @sale_offer = SaleOffer.find(params[:id])
  
      respond_to do |format|
        if @sale_offer.update_attributes(params[:sale_offer])
          format.html { redirect_to @sale_offer, notice: t('activerecord.attributes.sale_offer.succesfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sale_offers/1
    # DELETE /sale_offers/1.json
    def destroy
      @sale_offer = SaleOffer.find(params[:id])
      @sale_offer.destroy
  
      respond_to do |format|
        format.html { redirect_to sale_offers_url }
        format.json { head :no_content }
      end
    end
  end
end