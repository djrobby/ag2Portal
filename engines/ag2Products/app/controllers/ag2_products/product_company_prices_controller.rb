require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductCompanyPricesController < ApplicationController
    # GET /product_company_prices
    # GET /product_company_prices.json
    def index
      @product_company_prices = ProductCompanyPrice.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @product_company_prices }
      end
    end
  
    # GET /product_company_prices/1
    # GET /product_company_prices/1.json
    def show
      @product_company_price = ProductCompanyPrice.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product_company_price }
      end
    end
  
    # GET /product_company_prices/new
    # GET /product_company_prices/new.json
    def new
      @product_company_price = ProductCompanyPrice.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product_company_price }
      end
    end
  
    # GET /product_company_prices/1/edit
    def edit
      @product_company_price = ProductCompanyPrice.find(params[:id])
    end
  
    # POST /product_company_prices
    # POST /product_company_prices.json
    def create
      @product_company_price = ProductCompanyPrice.new(params[:product_company_price])
  
      respond_to do |format|
        if @product_company_price.save
          format.html { redirect_to @product_company_price, notice: 'Product company price was successfully created.' }
          format.json { render json: @product_company_price, status: :created, location: @product_company_price }
        else
          format.html { render action: "new" }
          format.json { render json: @product_company_price.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /product_company_prices/1
    # PUT /product_company_prices/1.json
    def update
      @product_company_price = ProductCompanyPrice.find(params[:id])
  
      respond_to do |format|
        if @product_company_price.update_attributes(params[:product_company_price])
          format.html { redirect_to @product_company_price, notice: 'Product company price was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product_company_price.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /product_company_prices/1
    # DELETE /product_company_prices/1.json
    def destroy
      @product_company_price = ProductCompanyPrice.find(params[:id])
      @product_company_price.destroy
  
      respond_to do |format|
        format.html { redirect_to product_company_prices_url }
        format.json { head :no_content }
      end
    end
  end
end
