require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class RegulationTypesController < ApplicationController
    # GET /regulation_types
    # GET /regulation_types.json
    def index
      @regulation_types = RegulationType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @regulation_types }
      end
    end
  
    # GET /regulation_types/1
    # GET /regulation_types/1.json
    def show
      @regulation_type = RegulationType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @regulation_type }
      end
    end
  
    # GET /regulation_types/new
    # GET /regulation_types/new.json
    def new
      @regulation_type = RegulationType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @regulation_type }
      end
    end
  
    # GET /regulation_types/1/edit
    def edit
      @regulation_type = RegulationType.find(params[:id])
    end
  
    # POST /regulation_types
    # POST /regulation_types.json
    def create
      @regulation_type = RegulationType.new(params[:regulation_type])
  
      respond_to do |format|
        if @regulation_type.save
          format.html { redirect_to @regulation_type, notice: 'Regulation type was successfully created.' }
          format.json { render json: @regulation_type, status: :created, location: @regulation_type }
        else
          format.html { render action: "new" }
          format.json { render json: @regulation_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /regulation_types/1
    # PUT /regulation_types/1.json
    def update
      @regulation_type = RegulationType.find(params[:id])
  
      respond_to do |format|
        if @regulation_type.update_attributes(params[:regulation_type])
          format.html { redirect_to @regulation_type, notice: 'Regulation type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @regulation_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /regulation_types/1
    # DELETE /regulation_types/1.json
    def destroy
      @regulation_type = RegulationType.find(params[:id])
      @regulation_type.destroy
  
      respond_to do |format|
        format.html { redirect_to regulation_types_url }
        format.json { head :no_content }
      end
    end
  end
end
