require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class TariffSchemeItemsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    def destroy
      @tariff_scheme_item = TariffSchemeItem.find(params[:id])
      tariff_scheme = @tariff_scheme_item.tariff_scheme

      respond_to do |format|
        if @tariff_scheme_item.destroy
          format.html { redirect_to tariff_scheme_url(tariff_scheme),
                      notice: (crud_notice('destroyed', @tariff_scheme_item) + "#{undo_link(@tariff_scheme_item)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to tariff_scheme_url(tariff_scheme), alert: "#{@tariff_scheme_item.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @tariff_scheme_item.errors, status: :unprocessable_entity }
        end
      end
    end

  end
end
