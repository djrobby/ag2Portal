require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryTransfersController < ApplicationController
    # GET /inventory_transfers
    # GET /inventory_transfers.json
    def index
      @inventory_transfers = InventoryTransfer.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inventory_transfers }
      end
    end
  
    # GET /inventory_transfers/1
    # GET /inventory_transfers/1.json
    def show
      @inventory_transfer = InventoryTransfer.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inventory_transfer }
      end
    end
  
    # GET /inventory_transfers/new
    # GET /inventory_transfers/new.json
    def new
      @inventory_transfer = InventoryTransfer.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_transfer }
      end
    end
  
    # GET /inventory_transfers/1/edit
    def edit
      @inventory_transfer = InventoryTransfer.find(params[:id])
    end
  
    # POST /inventory_transfers
    # POST /inventory_transfers.json
    def create
      @inventory_transfer = InventoryTransfer.new(params[:inventory_transfer])
  
      respond_to do |format|
        if @inventory_transfer.save
          format.html { redirect_to @inventory_transfer, notice: 'Inventory transfer was successfully created.' }
          format.json { render json: @inventory_transfer, status: :created, location: @inventory_transfer }
        else
          format.html { render action: "new" }
          format.json { render json: @inventory_transfer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /inventory_transfers/1
    # PUT /inventory_transfers/1.json
    def update
      @inventory_transfer = InventoryTransfer.find(params[:id])
  
      respond_to do |format|
        if @inventory_transfer.update_attributes(params[:inventory_transfer])
          format.html { redirect_to @inventory_transfer, notice: 'Inventory transfer was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @inventory_transfer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventory_transfers/1
    # DELETE /inventory_transfers/1.json
    def destroy
      @inventory_transfer = InventoryTransfer.find(params[:id])
      @inventory_transfer.destroy
  
      respond_to do |format|
        format.html { redirect_to inventory_transfers_url }
        format.json { head :no_content }
      end
    end
  end
end
