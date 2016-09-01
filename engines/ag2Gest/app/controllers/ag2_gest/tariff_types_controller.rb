require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class TariffTypesController < ApplicationController
    # GET /tariff_types
    # GET /tariff_types.json
    def index
      @tariff_types = TariffType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tariff_types }
      end
    end
  
    # GET /tariff_types/1
    # GET /tariff_types/1.json
    def show
      @tariff_type = TariffType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tariff_type }
      end
    end
  
    # GET /tariff_types/new
    # GET /tariff_types/new.json
    def new
      @tariff_type = TariffType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tariff_type }
      end
    end
  
    # GET /tariff_types/1/edit
    def edit
      @tariff_type = TariffType.find(params[:id])
    end
  
    # POST /tariff_types
    # POST /tariff_types.json
    def create
      @tariff_type = TariffType.new(params[:tariff_type])
  
      respond_to do |format|
        if @tariff_type.save
          format.html { redirect_to @tariff_type, notice: 'Tariff type was successfully created.' }
          format.json { render json: @tariff_type, status: :created, location: @tariff_type }
        else
          format.html { render action: "new" }
          format.json { render json: @tariff_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /tariff_types/1
    # PUT /tariff_types/1.json
    def update
      @tariff_type = TariffType.find(params[:id])
  
      respond_to do |format|
        if @tariff_type.update_attributes(params[:tariff_type])
          format.html { redirect_to @tariff_type, notice: 'Tariff type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @tariff_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tariff_types/1
    # DELETE /tariff_types/1.json
    def destroy
      @tariff_type = TariffType.find(params[:id])
      @tariff_type.destroy
  
      respond_to do |format|
        format.html { redirect_to tariff_types_url }
        format.json { head :no_content }
      end
    end
  end
end
