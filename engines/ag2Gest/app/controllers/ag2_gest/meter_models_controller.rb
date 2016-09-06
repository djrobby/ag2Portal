require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterModelsController < ApplicationController
    # GET /meter_models
    # GET /meter_models.json
    def index
      @meter_models = MeterModel.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_models }
      end
    end
  
    # GET /meter_models/1
    # GET /meter_models/1.json
    def show
      @meter_model = MeterModel.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_model }
      end
    end
  
    # GET /meter_models/new
    # GET /meter_models/new.json
    def new
      @meter_model = MeterModel.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_model }
      end
    end
  
    # GET /meter_models/1/edit
    def edit
      @meter_model = MeterModel.find(params[:id])
    end
  
    # POST /meter_models
    # POST /meter_models.json
    def create
      @meter_model = MeterModel.new(params[:meter_model])
  
      respond_to do |format|
        if @meter_model.save
          format.html { redirect_to @meter_model, notice: 'Meter model was successfully created.' }
          format.json { render json: @meter_model, status: :created, location: @meter_model }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_model.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /meter_models/1
    # PUT /meter_models/1.json
    def update
      @meter_model = MeterModel.find(params[:id])
  
      respond_to do |format|
        if @meter_model.update_attributes(params[:meter_model])
          format.html { redirect_to @meter_model, notice: 'Meter model was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_model.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /meter_models/1
    # DELETE /meter_models/1.json
    def destroy
      @meter_model = MeterModel.find(params[:id])
      @meter_model.destroy
  
      respond_to do |format|
        format.html { redirect_to meter_models_url }
        format.json { head :no_content }
      end
    end
  end
end
