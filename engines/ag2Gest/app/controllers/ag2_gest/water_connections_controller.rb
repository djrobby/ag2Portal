require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionsController < ApplicationController
    # GET /water_connections
    # GET /water_connections.json
    def index
      @water_connections = WaterConnection.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connections }
      end
    end
  
    # GET /water_connections/1
    # GET /water_connections/1.json
    def show
      @water_connection = WaterConnection.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection }
      end
    end
  
    # GET /water_connections/new
    # GET /water_connections/new.json
    def new
      @water_connection = WaterConnection.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_connection }
      end
    end
  
    # GET /water_connections/1/edit
    def edit
      @water_connection = WaterConnection.find(params[:id])
    end
  
    # POST /water_connections
    # POST /water_connections.json
    def create
      @water_connection = WaterConnection.new(params[:water_connection])
  
      respond_to do |format|
        if @water_connection.save
          format.html { redirect_to @water_connection, notice: 'Water connection was successfully created.' }
          format.json { render json: @water_connection, status: :created, location: @water_connection }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_connections/1
    # PUT /water_connections/1.json
    def update
      @water_connection = WaterConnection.find(params[:id])
  
      respond_to do |format|
        if @water_connection.update_attributes(params[:water_connection])
          format.html { redirect_to @water_connection, notice: 'Water connection was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_connections/1
    # DELETE /water_connections/1.json
    def destroy
      @water_connection = WaterConnection.find(params[:id])
      @water_connection.destroy
  
      respond_to do |format|
        format.html { redirect_to water_connections_url }
        format.json { head :no_content }
      end
    end
  end
end
