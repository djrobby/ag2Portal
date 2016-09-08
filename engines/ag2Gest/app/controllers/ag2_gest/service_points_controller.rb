require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointsController < ApplicationController
    # GET /service_points
    # GET /service_points.json
    def index
      @service_points = ServicePoint.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_points }
      end
    end
  
    # GET /service_points/1
    # GET /service_points/1.json
    def show
      @service_point = ServicePoint.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point }
      end
    end
  
    # GET /service_points/new
    # GET /service_points/new.json
    def new
      @service_point = ServicePoint.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point }
      end
    end
  
    # GET /service_points/1/edit
    def edit
      @service_point = ServicePoint.find(params[:id])
    end
  
    # POST /service_points
    # POST /service_points.json
    def create
      @service_point = ServicePoint.new(params[:service_point])
  
      respond_to do |format|
        if @service_point.save
          format.html { redirect_to @service_point, notice: 'Service point was successfully created.' }
          format.json { render json: @service_point, status: :created, location: @service_point }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /service_points/1
    # PUT /service_points/1.json
    def update
      @service_point = ServicePoint.find(params[:id])
  
      respond_to do |format|
        if @service_point.update_attributes(params[:service_point])
          format.html { redirect_to @service_point, notice: 'Service point was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /service_points/1
    # DELETE /service_points/1.json
    def destroy
      @service_point = ServicePoint.find(params[:id])
      @service_point.destroy
  
      respond_to do |format|
        format.html { redirect_to service_points_url }
        format.json { head :no_content }
      end
    end
  end
end
