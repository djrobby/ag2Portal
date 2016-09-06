require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterOwnersController < ApplicationController
    # GET /meter_owners
    # GET /meter_owners.json
    def index
      @meter_owners = MeterOwner.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_owners }
      end
    end
  
    # GET /meter_owners/1
    # GET /meter_owners/1.json
    def show
      @meter_owner = MeterOwner.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_owner }
      end
    end
  
    # GET /meter_owners/new
    # GET /meter_owners/new.json
    def new
      @meter_owner = MeterOwner.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_owner }
      end
    end
  
    # GET /meter_owners/1/edit
    def edit
      @meter_owner = MeterOwner.find(params[:id])
    end
  
    # POST /meter_owners
    # POST /meter_owners.json
    def create
      @meter_owner = MeterOwner.new(params[:meter_owner])
  
      respond_to do |format|
        if @meter_owner.save
          format.html { redirect_to @meter_owner, notice: 'Meter owner was successfully created.' }
          format.json { render json: @meter_owner, status: :created, location: @meter_owner }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_owner.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /meter_owners/1
    # PUT /meter_owners/1.json
    def update
      @meter_owner = MeterOwner.find(params[:id])
  
      respond_to do |format|
        if @meter_owner.update_attributes(params[:meter_owner])
          format.html { redirect_to @meter_owner, notice: 'Meter owner was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_owner.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /meter_owners/1
    # DELETE /meter_owners/1.json
    def destroy
      @meter_owner = MeterOwner.find(params[:id])
      @meter_owner.destroy
  
      respond_to do |format|
        format.html { redirect_to meter_owners_url }
        format.json { head :no_content }
      end
    end
  end
end
