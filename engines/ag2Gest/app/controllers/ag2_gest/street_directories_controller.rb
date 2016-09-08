require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class StreetDirectoriesController < ApplicationController
    # GET /street_directories
    # GET /street_directories.json
    def index
      @street_directories = StreetDirectory.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @street_directories }
      end
    end
  
    # GET /street_directories/1
    # GET /street_directories/1.json
    def show
      @street_directory = StreetDirectory.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @street_directory }
      end
    end
  
    # GET /street_directories/new
    # GET /street_directories/new.json
    def new
      @street_directory = StreetDirectory.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @street_directory }
      end
    end
  
    # GET /street_directories/1/edit
    def edit
      @street_directory = StreetDirectory.find(params[:id])
    end
  
    # POST /street_directories
    # POST /street_directories.json
    def create
      @street_directory = StreetDirectory.new(params[:street_directory])
  
      respond_to do |format|
        if @street_directory.save
          format.html { redirect_to @street_directory, notice: 'Street directory was successfully created.' }
          format.json { render json: @street_directory, status: :created, location: @street_directory }
        else
          format.html { render action: "new" }
          format.json { render json: @street_directory.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /street_directories/1
    # PUT /street_directories/1.json
    def update
      @street_directory = StreetDirectory.find(params[:id])
  
      respond_to do |format|
        if @street_directory.update_attributes(params[:street_directory])
          format.html { redirect_to @street_directory, notice: 'Street directory was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @street_directory.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /street_directories/1
    # DELETE /street_directories/1.json
    def destroy
      @street_directory = StreetDirectory.find(params[:id])
      @street_directory.destroy
  
      respond_to do |format|
        format.html { redirect_to street_directories_url }
        format.json { head :no_content }
      end
    end
  end
end
