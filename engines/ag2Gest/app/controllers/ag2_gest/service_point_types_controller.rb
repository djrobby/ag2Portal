require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointTypesController < ApplicationController
    # GET /service_point_types
    # GET /service_point_types.json
    def index
      @service_point_types = ServicePointType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_types }
      end
    end
  
    # GET /service_point_types/1
    # GET /service_point_types/1.json
    def show
      @service_point_type = ServicePointType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_type }
      end
    end
  
    # GET /service_point_types/new
    # GET /service_point_types/new.json
    def new
      @service_point_type = ServicePointType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_type }
      end
    end
  
    # GET /service_point_types/1/edit
    def edit
      @service_point_type = ServicePointType.find(params[:id])
    end
  
    # POST /service_point_types
    # POST /service_point_types.json
    def create
      @service_point_type = ServicePointType.new(params[:service_point_type])
  
      respond_to do |format|
        if @service_point_type.save
          format.html { redirect_to @service_point_type, notice: 'Service point type was successfully created.' }
          format.json { render json: @service_point_type, status: :created, location: @service_point_type }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /service_point_types/1
    # PUT /service_point_types/1.json
    def update
      @service_point_type = ServicePointType.find(params[:id])
  
      respond_to do |format|
        if @service_point_type.update_attributes(params[:service_point_type])
          format.html { redirect_to @service_point_type, notice: 'Service point type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /service_point_types/1
    # DELETE /service_point_types/1.json
    def destroy
      @service_point_type = ServicePointType.find(params[:id])
      @service_point_type.destroy
  
      respond_to do |format|
        format.html { redirect_to service_point_types_url }
        format.json { head :no_content }
      end
    end
  end
end
