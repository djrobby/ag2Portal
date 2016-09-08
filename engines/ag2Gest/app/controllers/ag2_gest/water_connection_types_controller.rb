require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionTypesController < ApplicationController
    # GET /water_connection_types
    # GET /water_connection_types.json
    def index
      @water_connection_types = WaterConnectionType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connection_types }
      end
    end
  
    # GET /water_connection_types/1
    # GET /water_connection_types/1.json
    def show
      @water_connection_type = WaterConnectionType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection_type }
      end
    end
  
    # GET /water_connection_types/new
    # GET /water_connection_types/new.json
    def new
      @water_connection_type = WaterConnectionType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_connection_type }
      end
    end
  
    # GET /water_connection_types/1/edit
    def edit
      @water_connection_type = WaterConnectionType.find(params[:id])
    end
  
    # POST /water_connection_types
    # POST /water_connection_types.json
    def create
      @water_connection_type = WaterConnectionType.new(params[:water_connection_type])
  
      respond_to do |format|
        if @water_connection_type.save
          format.html { redirect_to @water_connection_type, notice: 'Water connection type was successfully created.' }
          format.json { render json: @water_connection_type, status: :created, location: @water_connection_type }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_connection_types/1
    # PUT /water_connection_types/1.json
    def update
      @water_connection_type = WaterConnectionType.find(params[:id])
  
      respond_to do |format|
        if @water_connection_type.update_attributes(params[:water_connection_type])
          format.html { redirect_to @water_connection_type, notice: 'Water connection type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_connection_types/1
    # DELETE /water_connection_types/1.json
    def destroy
      @water_connection_type = WaterConnectionType.find(params[:id])
      @water_connection_type.destroy
  
      respond_to do |format|
        format.html { redirect_to water_connection_types_url }
        format.json { head :no_content }
      end
    end
  end
end
