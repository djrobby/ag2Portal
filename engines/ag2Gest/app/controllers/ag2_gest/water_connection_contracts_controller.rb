require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionContractsController < ApplicationController
    # GET /water_connection_contracts
    # GET /water_connection_contracts.json
    def index
      @water_connection_contracts = WaterConnectionContract.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connection_contracts }
      end
    end
  
    # GET /water_connection_contracts/1
    # GET /water_connection_contracts/1.json
    def show
      @water_connection_contract = WaterConnectionContract.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection_contract }
      end
    end
  
    # GET /water_connection_contracts/new
    # GET /water_connection_contracts/new.json
    def new
      @water_connection_contract = WaterConnectionContract.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_connection_contract }
      end
    end
  
    # GET /water_connection_contracts/1/edit
    def edit
      @water_connection_contract = WaterConnectionContract.find(params[:id])
    end
  
    # POST /water_connection_contracts
    # POST /water_connection_contracts.json
    def create
      @water_connection_contract = WaterConnectionContract.new(params[:water_connection_contract])
  
      respond_to do |format|
        if @water_connection_contract.save
          format.html { redirect_to @water_connection_contract, notice: 'Water connection contract was successfully created.' }
          format.json { render json: @water_connection_contract, status: :created, location: @water_connection_contract }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_connection_contracts/1
    # PUT /water_connection_contracts/1.json
    def update
      @water_connection_contract = WaterConnectionContract.find(params[:id])
  
      respond_to do |format|
        if @water_connection_contract.update_attributes(params[:water_connection_contract])
          format.html { redirect_to @water_connection_contract, notice: 'Water connection contract was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_connection_contracts/1
    # DELETE /water_connection_contracts/1.json
    def destroy
      @water_connection_contract = WaterConnectionContract.find(params[:id])
      @water_connection_contract.destroy
  
      respond_to do |format|
        format.html { redirect_to water_connection_contracts_url }
        format.json { head :no_content }
      end
    end
  end
end
