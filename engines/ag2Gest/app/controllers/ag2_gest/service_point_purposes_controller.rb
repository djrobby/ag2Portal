require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointPurposesController < ApplicationController
    # GET /service_point_purposes
    # GET /service_point_purposes.json
    def index
      @service_point_purposes = ServicePointPurpose.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_purposes }
      end
    end
  
    # GET /service_point_purposes/1
    # GET /service_point_purposes/1.json
    def show
      @service_point_purpose = ServicePointPurpose.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_purpose }
      end
    end
  
    # GET /service_point_purposes/new
    # GET /service_point_purposes/new.json
    def new
      @service_point_purpose = ServicePointPurpose.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_purpose }
      end
    end
  
    # GET /service_point_purposes/1/edit
    def edit
      @service_point_purpose = ServicePointPurpose.find(params[:id])
    end
  
    # POST /service_point_purposes
    # POST /service_point_purposes.json
    def create
      @service_point_purpose = ServicePointPurpose.new(params[:service_point_purpose])
  
      respond_to do |format|
        if @service_point_purpose.save
          format.html { redirect_to @service_point_purpose, notice: 'Service point purpose was successfully created.' }
          format.json { render json: @service_point_purpose, status: :created, location: @service_point_purpose }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_purpose.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /service_point_purposes/1
    # PUT /service_point_purposes/1.json
    def update
      @service_point_purpose = ServicePointPurpose.find(params[:id])
  
      respond_to do |format|
        if @service_point_purpose.update_attributes(params[:service_point_purpose])
          format.html { redirect_to @service_point_purpose, notice: 'Service point purpose was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_purpose.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /service_point_purposes/1
    # DELETE /service_point_purposes/1.json
    def destroy
      @service_point_purpose = ServicePointPurpose.find(params[:id])
      @service_point_purpose.destroy
  
      respond_to do |format|
        format.html { redirect_to service_point_purposes_url }
        format.json { head :no_content }
      end
    end
  end
end
