require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class PreReadingsController < ApplicationController
    # GET /pre_readings
    # GET /pre_readings.json
    def index
      @pre_readings = PreReading.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @pre_readings }
      end
    end
  
    # GET /pre_readings/1
    # GET /pre_readings/1.json
    def show
      @pre_reading = PreReading.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @pre_reading }
      end
    end
  
    # GET /pre_readings/new
    # GET /pre_readings/new.json
    def new
      @pre_reading = PreReading.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @pre_reading }
      end
    end
  
    # GET /pre_readings/1/edit
    def edit
      @pre_reading = PreReading.find(params[:id])
    end
  
    # POST /pre_readings
    # POST /pre_readings.json
    def create
      @pre_reading = PreReading.new(params[:pre_reading])
  
      respond_to do |format|
        if @pre_reading.save
          format.html { redirect_to @pre_reading, notice: 'Pre reading was successfully created.' }
          format.json { render json: @pre_reading, status: :created, location: @pre_reading }
        else
          format.html { render action: "new" }
          format.json { render json: @pre_reading.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /pre_readings/1
    # PUT /pre_readings/1.json
    def update
      @pre_reading = PreReading.find(params[:id])
  
      respond_to do |format|
        if @pre_reading.update_attributes(params[:pre_reading])
          format.html { redirect_to @pre_reading, notice: 'Pre reading was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @pre_reading.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /pre_readings/1
    # DELETE /pre_readings/1.json
    def destroy
      @pre_reading = PreReading.find(params[:id])
      @pre_reading.destroy
  
      respond_to do |format|
        format.html { redirect_to pre_readings_url }
        format.json { head :no_content }
      end
    end
  end
end
