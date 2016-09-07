require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterSupplyContractsController < ApplicationController
    # GET /water_supply_contracts
    # GET /water_supply_contracts.json
    def index
      @water_supply_contracts = WaterSupplyContract.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_supply_contracts }
      end
    end
  
    # GET /water_supply_contracts/1
    # GET /water_supply_contracts/1.json
    def show
      @water_supply_contract = WaterSupplyContract.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_supply_contract }
      end
    end
  
    # GET /water_supply_contracts/new
    # GET /water_supply_contracts/new.json
    def new
      @water_supply_contract = WaterSupplyContract.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_supply_contract }
      end
    end
  
    # GET /water_supply_contracts/1/edit
    def edit
      @water_supply_contract = WaterSupplyContract.find(params[:id])
    end
  
    # POST /water_supply_contracts
    # POST /water_supply_contracts.json
    def create
      @water_supply_contract = WaterSupplyContract.new(params[:water_supply_contract])
  
      respond_to do |format|
        if @water_supply_contract.save
          format.html { redirect_to @water_supply_contract, notice: 'Water supply contract was successfully created.' }
          format.json { render json: @water_supply_contract, status: :created, location: @water_supply_contract }
        else
          format.html { render action: "new" }
          format.json { render json: @water_supply_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_supply_contracts/1
    # PUT /water_supply_contracts/1.json
    def update
      @water_supply_contract = WaterSupplyContract.find(params[:id])
  
      respond_to do |format|
        if @water_supply_contract.update_attributes(params[:water_supply_contract])
          format.html { redirect_to @water_supply_contract, notice: 'Water supply contract was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_supply_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_supply_contracts/1
    # DELETE /water_supply_contracts/1.json
    def destroy
      @water_supply_contract = WaterSupplyContract.find(params[:id])
      @water_supply_contract.destroy
  
      respond_to do |format|
        format.html { redirect_to water_supply_contracts_url }
        format.json { head :no_content }
      end
    end
  end
end
