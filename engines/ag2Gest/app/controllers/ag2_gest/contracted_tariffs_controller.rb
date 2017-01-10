require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractedTariffsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    def destroy
      @contracted_tariff = ContractedTariff.find(params[:id])
      water_supply_contract = @contracted_tariff.water_supply_contract

      if water_supply_contract.bill.blank?
        respond_to do |format|
          if @contracted_tariff.destroy
            format.html { redirect_to contracting_request_url(water_supply_contract.contracting_request),
                        notice: (crud_notice('destroyed', @contracted_tariff) + "#{undo_link(@contracted_tariff)}").html_safe }
            format.json { head :no_content }
          else
            format.html { redirect_to contracting_request_url(water_supply_contract.contracting_request), alert: "#{@contracted_tariff.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
            format.json { render json: @contracted_tariff.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to contracting_request_url(water_supply_contract.contracting_request), alert: "No se puede eliminar tarifas con factura ya creada"
      end
    end

  end
end
