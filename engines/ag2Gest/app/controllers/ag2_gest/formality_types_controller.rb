require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class FormalityTypesController < ApplicationController
    # GET /formality_types
    # GET /formality_types.json
    def index
      @formality_types = FormalityType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @formality_types }
      end
    end
  
    # GET /formality_types/1
    # GET /formality_types/1.json
    def show
      @formality_type = FormalityType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @formality_type }
      end
    end
  
    # GET /formality_types/new
    # GET /formality_types/new.json
    def new
      @formality_type = FormalityType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @formality_type }
      end
    end
  
    # GET /formality_types/1/edit
    def edit
      @formality_type = FormalityType.find(params[:id])
    end
  
    # POST /formality_types
    # POST /formality_types.json
    def create
      @formality_type = FormalityType.new(params[:formality_type])
  
      respond_to do |format|
        if @formality_type.save
          format.html { redirect_to @formality_type, notice: 'Formality type was successfully created.' }
          format.json { render json: @formality_type, status: :created, location: @formality_type }
        else
          format.html { render action: "new" }
          format.json { render json: @formality_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /formality_types/1
    # PUT /formality_types/1.json
    def update
      @formality_type = FormalityType.find(params[:id])
  
      respond_to do |format|
        if @formality_type.update_attributes(params[:formality_type])
          format.html { redirect_to @formality_type, notice: 'Formality type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @formality_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /formality_types/1
    # DELETE /formality_types/1.json
    def destroy
      @formality_type = FormalityType.find(params[:id])
      @formality_type.destroy
  
      respond_to do |format|
        format.html { redirect_to formality_types_url }
        format.json { head :no_content }
      end
    end
  end
end
