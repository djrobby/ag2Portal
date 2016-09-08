require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointLocationsController < ApplicationController
    # GET /service_point_locations
    # GET /service_point_locations.json
    def index
      @service_point_locations = ServicePointLocation.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_locations }
      end
    end
  
    # GET /service_point_locations/1
    # GET /service_point_locations/1.json
    def show
      @service_point_location = ServicePointLocation.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_location }
      end
    end
  
    # GET /service_point_locations/new
    # GET /service_point_locations/new.json
    def new
      @service_point_location = ServicePointLocation.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_location }
      end
    end
  
    # GET /service_point_locations/1/edit
    def edit
      @service_point_location = ServicePointLocation.find(params[:id])
    end
  
    # POST /service_point_locations
    # POST /service_point_locations.json
    def create
      @service_point_location = ServicePointLocation.new(params[:service_point_location])
  
      respond_to do |format|
        if @service_point_location.save
          format.html { redirect_to @service_point_location, notice: 'Service point location was successfully created.' }
          format.json { render json: @service_point_location, status: :created, location: @service_point_location }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_location.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /service_point_locations/1
    # PUT /service_point_locations/1.json
    def update
      @service_point_location = ServicePointLocation.find(params[:id])
  
      respond_to do |format|
        if @service_point_location.update_attributes(params[:service_point_location])
          format.html { redirect_to @service_point_location, notice: 'Service point location was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_location.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /service_point_locations/1
    # DELETE /service_point_locations/1.json
    def destroy
      @service_point_location = ServicePointLocation.find(params[:id])
      @service_point_location.destroy
  
      respond_to do |format|
        format.html { redirect_to service_point_locations_url }
        format.json { head :no_content }
      end
    end
  end
end
