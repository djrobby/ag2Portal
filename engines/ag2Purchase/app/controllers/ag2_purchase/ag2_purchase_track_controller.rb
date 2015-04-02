require_dependency "ag2_human/application_controller"

module Ag2Purchase
  class Ag2PurchaseTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:purchase_order_form]

    # Report
    def purchase_order_form
      id = params[:report_id]
      if id.blank? 
        return
      end

      # Search purchase order & items
      @purchase_order = PurchaseOrder.find(id)
      @items = @purchase_order.purchase_order_items.order('id')

      title = t("activerecord.models.purchase_order.one")      

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@purchase_order.order_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end
  end
end
