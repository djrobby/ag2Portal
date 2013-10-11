require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductFamiliesController < ApplicationController
    # GET /product_families
    # GET /product_families.json
    def index
      @product_families = ProductFamily.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @product_families }
      end
    end
  
    # GET /product_families/1
    # GET /product_families/1.json
    def show
      @product_family = ProductFamily.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product_family }
      end
    end
  
    # GET /product_families/new
    # GET /product_families/new.json
    def new
      @product_family = ProductFamily.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product_family }
      end
    end
  
    # GET /product_families/1/edit
    def edit
      @product_family = ProductFamily.find(params[:id])
    end
  
    # POST /product_families
    # POST /product_families.json
    def create
      @product_family = ProductFamily.new(params[:product_family])
  
      respond_to do |format|
        if @product_family.save
          format.html { redirect_to @product_family, notice: 'Product family was successfully created.' }
          format.json { render json: @product_family, status: :created, location: @product_family }
        else
          format.html { render action: "new" }
          format.json { render json: @product_family.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /product_families/1
    # PUT /product_families/1.json
    def update
      @product_family = ProductFamily.find(params[:id])
  
      respond_to do |format|
        if @product_family.update_attributes(params[:product_family])
          format.html { redirect_to @product_family, notice: 'Product family was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product_family.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /product_families/1
    # DELETE /product_families/1.json
    def destroy
      @product_family = ProductFamily.find(params[:id])
      @product_family.destroy
  
      respond_to do |format|
        format.html { redirect_to product_families_url }
        format.json { head :no_content }
      end
    end
  end
end
