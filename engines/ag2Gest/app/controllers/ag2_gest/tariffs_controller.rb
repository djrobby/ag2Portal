require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class TariffsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /tariffs
    # GET /tariffs.json
    def index
      @tariffs = Tariff.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tariffs }
        format.js
      end
    end

    # PUT /tariffs/1
    # PUT /tariffs/1.json
    def update
      @tariff = Tariff.find(params[:id])
      @tariff_scheme = @tariff.tariff_scheme

      respond_to do |format|
        if @tariff.update_attributes(params[:tariff])
          format.html { redirect_to tariff_scheme_url(@tariff_scheme), notice: "Tarifa modificada" }
          format.json { head :no_content }
        else
          format.html { redirect_to tariff_scheme_url(@tariff_scheme), alert: "Error al modificar la tarifa" }
          format.json { render json: @tariff.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tariffs/1
    # DELETE /tariffs/1.json
    def destroy
      @tariff = Tariff.find(params[:id])
      @tariff_scheme = @tariff.tariff_scheme
      @tariff.block1_fee = 0.0
      @tariff.block2_fee = 0.0
      @tariff.block3_fee = 0.0
      @tariff.block4_fee = 0.0
      @tariff.block5_fee = 0.0
      @tariff.block6_fee = 0.0
      @tariff.block7_fee = 0.0
      @tariff.block8_fee = 0.0
      @tariff.fixed_fee = 0.0
      @tariff.variable_fee = 0.0
      @tariff.percentage_fee = 0.0

      respond_to do |format|
        if @tariff.save
          format.html { redirect_to tariff_scheme_url(@tariff_scheme), notice: "Tarifa eliminada" }
          format.json { render json: @tariff_scheme, status: :created, location: @tariff_scheme }
        else
          format.html { redirect_to tariff_scheme_url(@tariff_scheme), alert: "Error al eliminar tarifa" }
          format.json { render json: @tariff_scheme.errors, status: :unprocessable_entity }
        end
      end

    end
  end
end
