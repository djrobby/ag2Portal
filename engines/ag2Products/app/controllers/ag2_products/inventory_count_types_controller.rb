require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryCountTypesController < ApplicationController
    # GET /inventory_count_types
    # GET /inventory_count_types.json
    def index
      @inventory_count_types = InventoryCountType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inventory_count_types }
      end
    end
  
    # GET /inventory_count_types/1
    # GET /inventory_count_types/1.json
    def show
      @inventory_count_type = InventoryCountType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inventory_count_type }
      end
    end
  
    # GET /inventory_count_types/new
    # GET /inventory_count_types/new.json
    def new
      @inventory_count_type = InventoryCountType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_count_type }
      end
    end
  
    # GET /inventory_count_types/1/edit
    def edit
      @inventory_count_type = InventoryCountType.find(params[:id])
    end
  
    # POST /inventory_count_types
    # POST /inventory_count_types.json
    def create
      @inventory_count_type = InventoryCountType.new(params[:inventory_count_type])
  
      respond_to do |format|
        if @inventory_count_type.save
          format.html { redirect_to @inventory_count_type, notice: 'Inventory count type was successfully created.' }
          format.json { render json: @inventory_count_type, status: :created, location: @inventory_count_type }
        else
          format.html { render action: "new" }
          format.json { render json: @inventory_count_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /inventory_count_types/1
    # PUT /inventory_count_types/1.json
    def update
      @inventory_count_type = InventoryCountType.find(params[:id])
  
      respond_to do |format|
        if @inventory_count_type.update_attributes(params[:inventory_count_type])
          format.html { redirect_to @inventory_count_type, notice: 'Inventory count type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @inventory_count_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventory_count_types/1
    # DELETE /inventory_count_types/1.json
    def destroy
      @inventory_count_type = InventoryCountType.find(params[:id])
      @inventory_count_type.destroy
  
      respond_to do |format|
        format.html { redirect_to inventory_count_types_url }
        format.json { head :no_content }
      end
    end
  end
end
