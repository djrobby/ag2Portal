require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryCountsController < ApplicationController
    # GET /inventory_counts
    # GET /inventory_counts.json
    def index
      @inventory_counts = InventoryCount.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inventory_counts }
      end
    end
  
    # GET /inventory_counts/1
    # GET /inventory_counts/1.json
    def show
      @inventory_count = InventoryCount.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inventory_count }
      end
    end
  
    # GET /inventory_counts/new
    # GET /inventory_counts/new.json
    def new
      @inventory_count = InventoryCount.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_count }
      end
    end
  
    # GET /inventory_counts/1/edit
    def edit
      @inventory_count = InventoryCount.find(params[:id])
    end
  
    # POST /inventory_counts
    # POST /inventory_counts.json
    def create
      @inventory_count = InventoryCount.new(params[:inventory_count])
  
      respond_to do |format|
        if @inventory_count.save
          format.html { redirect_to @inventory_count, notice: 'Inventory count was successfully created.' }
          format.json { render json: @inventory_count, status: :created, location: @inventory_count }
        else
          format.html { render action: "new" }
          format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /inventory_counts/1
    # PUT /inventory_counts/1.json
    def update
      @inventory_count = InventoryCount.find(params[:id])
  
      respond_to do |format|
        if @inventory_count.update_attributes(params[:inventory_count])
          format.html { redirect_to @inventory_count, notice: 'Inventory count was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventory_counts/1
    # DELETE /inventory_counts/1.json
    def destroy
      @inventory_count = InventoryCount.find(params[:id])
      @inventory_count.destroy
  
      respond_to do |format|
        format.html { redirect_to inventory_counts_url }
        format.json { head :no_content }
      end
    end
  end
end
