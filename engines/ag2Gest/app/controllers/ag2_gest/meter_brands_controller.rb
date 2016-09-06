require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterBrandsController < ApplicationController
    # GET /meter_brands
    # GET /meter_brands.json
    def index
      @meter_brands = MeterBrand.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_brands }
      end
    end
  
    # GET /meter_brands/1
    # GET /meter_brands/1.json
    def show
      @meter_brand = MeterBrand.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_brand }
      end
    end
  
    # GET /meter_brands/new
    # GET /meter_brands/new.json
    def new
      @meter_brand = MeterBrand.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_brand }
      end
    end
  
    # GET /meter_brands/1/edit
    def edit
      @meter_brand = MeterBrand.find(params[:id])
    end
  
    # POST /meter_brands
    # POST /meter_brands.json
    def create
      @meter_brand = MeterBrand.new(params[:meter_brand])
  
      respond_to do |format|
        if @meter_brand.save
          format.html { redirect_to @meter_brand, notice: 'Meter brand was successfully created.' }
          format.json { render json: @meter_brand, status: :created, location: @meter_brand }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_brand.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /meter_brands/1
    # PUT /meter_brands/1.json
    def update
      @meter_brand = MeterBrand.find(params[:id])
  
      respond_to do |format|
        if @meter_brand.update_attributes(params[:meter_brand])
          format.html { redirect_to @meter_brand, notice: 'Meter brand was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_brand.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /meter_brands/1
    # DELETE /meter_brands/1.json
    def destroy
      @meter_brand = MeterBrand.find(params[:id])
      @meter_brand.destroy
  
      respond_to do |format|
        format.html { redirect_to meter_brands_url }
        format.json { head :no_content }
      end
    end
  end
end
