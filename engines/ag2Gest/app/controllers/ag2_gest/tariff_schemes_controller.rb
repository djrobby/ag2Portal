require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class TariffSchemesController < ApplicationController
    # GET /tariff_schemes
    # GET /tariff_schemes.json
    def index
      @tariff_schemes = TariffScheme.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tariff_schemes }
      end
    end
  
    # GET /tariff_schemes/1
    # GET /tariff_schemes/1.json
    def show
      @tariff_scheme = TariffScheme.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tariff_scheme }
      end
    end
  
    # GET /tariff_schemes/new
    # GET /tariff_schemes/new.json
    def new
      @tariff_scheme = TariffScheme.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tariff_scheme }
      end
    end
  
    # GET /tariff_schemes/1/edit
    def edit
      @tariff_scheme = TariffScheme.find(params[:id])
    end
  
    # POST /tariff_schemes
    # POST /tariff_schemes.json
    def create
      @tariff_scheme = TariffScheme.new(params[:tariff_scheme])
  
      respond_to do |format|
        if @tariff_scheme.save
          format.html { redirect_to @tariff_scheme, notice: 'Tariff scheme was successfully created.' }
          format.json { render json: @tariff_scheme, status: :created, location: @tariff_scheme }
        else
          format.html { render action: "new" }
          format.json { render json: @tariff_scheme.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /tariff_schemes/1
    # PUT /tariff_schemes/1.json
    def update
      @tariff_scheme = TariffScheme.find(params[:id])
  
      respond_to do |format|
        if @tariff_scheme.update_attributes(params[:tariff_scheme])
          format.html { redirect_to @tariff_scheme, notice: 'Tariff scheme was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @tariff_scheme.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tariff_schemes/1
    # DELETE /tariff_schemes/1.json
    def destroy
      @tariff_scheme = TariffScheme.find(params[:id])
      @tariff_scheme.destroy
  
      respond_to do |format|
        format.html { redirect_to tariff_schemes_url }
        format.json { head :no_content }
      end
    end
  end
end
