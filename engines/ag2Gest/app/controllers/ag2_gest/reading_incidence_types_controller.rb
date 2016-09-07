require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingIncidenceTypesController < ApplicationController
    # GET /reading_incidence_types
    # GET /reading_incidence_types.json
    def index
      @reading_incidence_types = ReadingIncidenceType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @reading_incidence_types }
      end
    end
  
    # GET /reading_incidence_types/1
    # GET /reading_incidence_types/1.json
    def show
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading_incidence_type }
      end
    end
  
    # GET /reading_incidence_types/new
    # GET /reading_incidence_types/new.json
    def new
      @reading_incidence_type = ReadingIncidenceType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading_incidence_type }
      end
    end
  
    # GET /reading_incidence_types/1/edit
    def edit
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
    end
  
    # POST /reading_incidence_types
    # POST /reading_incidence_types.json
    def create
      @reading_incidence_type = ReadingIncidenceType.new(params[:reading_incidence_type])
  
      respond_to do |format|
        if @reading_incidence_type.save
          format.html { redirect_to @reading_incidence_type, notice: 'Reading incidence type was successfully created.' }
          format.json { render json: @reading_incidence_type, status: :created, location: @reading_incidence_type }
        else
          format.html { render action: "new" }
          format.json { render json: @reading_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /reading_incidence_types/1
    # PUT /reading_incidence_types/1.json
    def update
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
  
      respond_to do |format|
        if @reading_incidence_type.update_attributes(params[:reading_incidence_type])
          format.html { redirect_to @reading_incidence_type, notice: 'Reading incidence type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /reading_incidence_types/1
    # DELETE /reading_incidence_types/1.json
    def destroy
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
      @reading_incidence_type.destroy
  
      respond_to do |format|
        format.html { redirect_to reading_incidence_types_url }
        format.json { head :no_content }
      end
    end
  end
end
