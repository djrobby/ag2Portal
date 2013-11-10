require_dependency "ag2_products/application_controller"

module Ag2Products
  class PurchasePricesController < ApplicationController
    # GET /purchase_prices
    # GET /purchase_prices.json
    def index
      @purchase_prices = PurchasePrice.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @purchase_prices }
      end
    end
  
    # GET /purchase_prices/1
    # GET /purchase_prices/1.json
    def show
      @purchase_price = PurchasePrice.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @purchase_price }
      end
    end
  
    # GET /purchase_prices/new
    # GET /purchase_prices/new.json
    def new
      @purchase_price = PurchasePrice.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @purchase_price }
      end
    end
  
    # GET /purchase_prices/1/edit
    def edit
      @purchase_price = PurchasePrice.find(params[:id])
    end
  
    # POST /purchase_prices
    # POST /purchase_prices.json
    def create
      @purchase_price = PurchasePrice.new(params[:purchase_price])
  
      respond_to do |format|
        if @purchase_price.save
          format.html { redirect_to @purchase_price, notice: 'Purchase price was successfully created.' }
          format.json { render json: @purchase_price, status: :created, location: @purchase_price }
        else
          format.html { render action: "new" }
          format.json { render json: @purchase_price.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /purchase_prices/1
    # PUT /purchase_prices/1.json
    def update
      @purchase_price = PurchasePrice.find(params[:id])
  
      respond_to do |format|
        if @purchase_price.update_attributes(params[:purchase_price])
          format.html { redirect_to @purchase_price, notice: 'Purchase price was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @purchase_price.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /purchase_prices/1
    # DELETE /purchase_prices/1.json
    def destroy
      @purchase_price = PurchasePrice.find(params[:id])
      @purchase_price.destroy
  
      respond_to do |format|
        format.html { redirect_to purchase_prices_url }
        format.json { head :no_content }
      end
    end
  end
end
