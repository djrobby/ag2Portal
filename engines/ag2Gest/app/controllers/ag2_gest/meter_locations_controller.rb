require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterLocationsController < ApplicationController
    # GET /meter_locations
    # GET /meter_locations.json
    def index
      @meter_locations = MeterLocation.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_locations }
      end
    end
  
    # GET /meter_locations/1
    # GET /meter_locations/1.json
    def show
      @meter_location = MeterLocation.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_location }
      end
    end
  
    # GET /meter_locations/new
    # GET /meter_locations/new.json
    def new
      @meter_location = MeterLocation.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_location }
      end
    end
  
    # GET /meter_locations/1/edit
    def edit
      @meter_location = MeterLocation.find(params[:id])
    end
  
    # POST /meter_locations
    # POST /meter_locations.json
    def create
      @meter_location = MeterLocation.new(params[:meter_location])
  
      respond_to do |format|
        if @meter_location.save
          format.html { redirect_to @meter_location, notice: 'Meter location was successfully created.' }
          format.json { render json: @meter_location, status: :created, location: @meter_location }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_location.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /meter_locations/1
    # PUT /meter_locations/1.json
    def update
      @meter_location = MeterLocation.find(params[:id])
  
      respond_to do |format|
        if @meter_location.update_attributes(params[:meter_location])
          format.html { redirect_to @meter_location, notice: 'Meter location was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_location.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /meter_locations/1
    # DELETE /meter_locations/1.json
    def destroy
      @meter_location = MeterLocation.find(params[:id])
      @meter_location.destroy
  
      respond_to do |format|
        format.html { redirect_to meter_locations_url }
        format.json { head :no_content }
      end
    end
  end
end
