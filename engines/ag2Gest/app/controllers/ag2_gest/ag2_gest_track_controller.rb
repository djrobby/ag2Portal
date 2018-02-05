require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class Ag2GestTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:supply_contract_report,
                                               :connection_contract_report,
                                               :contracting_request_report,
                                               :pre_invoice_report,
                                               :invoice_report,
                                               :pending_invoice_report,
                                               :client_payment_report,
                                               :debt_claim_report,
                                               :pre_reading_report,
                                               :reading_report,
                                               :meter_report,
                                               :service_point_report,
                                               :subscriber_report,
                                               :client_report]

    def request_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND request_date >= ? AND request_date <= ?",project,store,order,account,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND request_date >= ? AND request_date <= ?",project,store,order,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND store_id = ? AND request_date >= ? AND request_date <= ?",project,store,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND request_date >= ? AND request_date <= ?",project,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND request_date >= ? AND request_date <= ?",project,store,account,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && !order.blank? && !account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND request_date >= ? AND request_date <= ?",project,order,account,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && !order.blank? && account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND work_order_id = ? AND request_date >= ? AND request_date <= ?",project,order,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && order.blank? && !account.blank?
        @request_report = OfferRequest.where("project_id in (?) AND charge_account_id = ? AND request_date >= ? AND request_date <= ?",project,account,from,to).order(:request_date)
       end

      # Setup filename
      title = t("activerecord.models.offer_request.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@request_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data OfferRequest.to_csv(@request_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def request_items_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.store_id = ? AND offer_requests.work_order_id = ? AND offer_requests.charge_account_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,store,order,account,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.store_id = ? AND offer_requests.work_order_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,store,order,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.store_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,store,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,from,to).order(:request_date)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.store_id = ? AND offer_requests.charge_account_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,store,account,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && !order.blank? && !account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.work_order_id = ? AND offer_requests.charge_account_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,order,account,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && !order.blank? && account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.work_order_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,order,from,to).order(:request_date)
      elsif !project.blank? && store.blank? && order.blank? && !account.blank?
        @request_items_report = OfferRequestItem.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.charge_account_id = ? AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",project,account,from,to).order(:request_date)
       end

      # Setup filename
      title = t("activerecord.models.offer_request.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@request_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data OfferRequestItem.to_csv(@request_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Offers report
    def offer_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @offer_report = Offer.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND offer_date >= ? AND offer_date <= ?",project,store,order,account,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @offer_report = Offer.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND offer_date >= ? AND offer_date <= ?",project,store,order,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @offer_report = Offer.where("project_id in (?) AND store_id = ? AND offer_date >= ? AND offer_date <= ?",project,store,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @offer_report = Offer.where("project_id in (?) AND offer_date >= ? AND offer_date <= ?",project,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @offer_report = Offer.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND offer_date >= ? AND offer_date <= ?",project,store,account,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && !order.blank? && !account.blank?
        @offer_report = Offer.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND offer_date >= ? AND offer_date <= ?",project,order,account,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && !order.blank? && account.blank?
        @offer_report = Offer.where("project_id in (?) AND work_order_id = ? AND offer_date >= ? AND offer_date <= ?",project,order,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && order.blank? && !account.blank?
        @offer_report = Offer.where("project_id in (?) AND charge_account_id = ? AND offer_date >= ? AND offer_date <= ?",project,account,from,to).order(:offer_date)
       end

      # Setup filename
      title = t("activerecord.models.supplier_invoice.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@offer_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Offer.to_csv(@offer_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Offers Items report
    def offer_items_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
  #    supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
   #   product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.store_id = ? AND offers.work_order_id = ? AND offers.charge_account_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,store,order,account,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.store_id = ? AND offers.work_order_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,store,order,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.store_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,store,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.offer_date >= ? AND offers.offer_date <= ?",project,from,to).order(:offer_date)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.store_id = ? AND offers.charge_account_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,store,account,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && !order.blank? && !account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.work_order_id = ? AND offers.charge_account_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,order,account,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && !order.blank? && account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.work_order_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,order,from,to).order(:offer_date)
      elsif !project.blank? && store.blank? && order.blank? && !account.blank?
        @offer_items_report = OfferItem.joins(:offer).where("offers.project_id in (?) AND offers.charge_account_id = ? AND offers.offer_date >= ? AND offers.offer_date <= ?",project,account,from,to).order(:offer_date)
       end



      # Setup filename
      title = t("activerecord.models.offer.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@offer_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data OfferItem.to_csv(@offer_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Purchase orders report
    def order_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      status = params[:status]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND order_date >= ? AND order_date <= ?",project,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND order_date >= ? AND order_date <= ?",project,store,from,to).order(:order_date)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,store,order,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,store,account,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,store,status,from,to).order(:order_date)

      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,order,account,status,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,order,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,account,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,status,from,to).order(:order_date)
      end

      # Setup filename
      title = t("activerecord.models.supplier_invoice.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@order_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data PurchaseOrder.to_csv(@order_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Orders Items report
    def order_items_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      status = params[:status]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,from,to).order(:order_date)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,from,to).order(:order_date)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,order,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,account,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,status,from,to).order(:order_date)

      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,account,status,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,account,from,to).order(:order_date)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,status,from,to).order(:order_date)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@order_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data PurchaseOrderItem.to_csv(@order_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Supplier invoices report
    def invoice_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND work_order_id = ? AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND work_order_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND invoice_date >= ? AND invoice_date <= ?",project,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND work_order_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND work_order_id = ? AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND work_order_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND supplier_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,supplier,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && !account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && account.blank?
        @invoice_report = SupplierInvoice.where("project_id in (?) AND work_order_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,order,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && !account.blank?
       @invoice_report = SupplierInvoice.where("project_id in (?) AND charge_account_id = ? AND invoice_date >= ? AND invoice_date <= ?",project,account,from,to).order(:invoice_date)
      end


      # Setup filename
      title = t("activerecord.models.supplier_invoice.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@invoice_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data SupplierInvoice.to_report_invoices_csv(@invoice_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Supplier invoices items report
    def invoice_items_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      #SupplierInvoice.joins(:supplier_invoice_approvals,:supplier_invoice_items)

      if !project.blank? && !supplier.blank? && !order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.work_order_id = ? AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.work_order_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.work_order_id = ? AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.work_order_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.work_order_id = ? AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && !order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.work_order_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,order,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,account,from,to).order(:invoice_date)
      elsif !project.blank? && !supplier.blank? && order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.supplier_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,supplier,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && !account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.work_order_id = ? AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,order,account,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && !order.blank? && account.blank?
        @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.work_order_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,order,from,to).order(:invoice_date)
      elsif !project.blank? && supplier.blank? && order.blank? && !account.blank?
       @invoice_items_report = SupplierInvoiceItem.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.charge_account_id = ? AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",project,account,from,to).order(:invoice_date)
      end


      # Setup filename
      title = t("activerecord.models.supplier_invoice.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@invoice_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data SupplierInvoiceItem.to_report_invoices_csv(@invoice_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Supplier payments report
    def payment_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank?
        @payment_report = SupplierPayment.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_payments.supplier_id = ? AND supplier_payments.payment_date >= ? AND supplier_payments.payment_date <= ?",project,supplier,from,to).order("supplier_payments.payment_date")
      elsif !project.blank? && supplier.blank?
        @payment_report = SupplierPayment.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_payments.payment_date >= ? AND supplier_payments.payment_date <= ?",project,from,to).order("supplier_payments.payment_date")
      end

      # Setup filename
      title = t("activerecord.models.supplier_payment.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@payment_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data SupplierPayment.to_csv(@payment_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Suppliers report
    def supplier_report
      detailed = params[:detailed]
      project = params[:project]
      supplier = params[:supplier]


      # Dates are mandatory
      from = Date.today.to_s

      if !project.blank? && !supplier.blank?
        @supplier_report = Supplier.joins(:supplier_invoices).where("supplier_invoices.project_id = ? AND suppliers.id = ?", project,supplier).order("suppliers.supplier_code")
      elsif project.blank? && !supplier.blank?
        @supplier_report = Supplier.joins(:supplier_invoices).where("suppliers.id = ?",supplier).order("suppliers.supplier_code")
      elsif !project.blank? && supplier.blank?
        @supplier_report = Supplier.joins(:supplier_invoices).where("supplier_invoices.project_id = ? ",project).order("suppliers.supplier_code")
      elsif project.blank? && supplier.blank?
        @supplier_report = Supplier.joins(:supplier_invoices).order("suppliers.supplier_code")
      end

      # Setup filename
      title = t("activerecord.models.supplier.few") + "_#{from}"

      respond_to do |format|
        # Render PDF
        if !@supplier_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Supplier.to_csv(@supplier_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Suppliers prices report
    def supplier_prices_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

     if !supplier.blank?
         @supplier_prices_report = PurchasePrice.joins(:supplier).where("supplier_id = ? AND purchase_prices.created_at >= ? AND purchase_prices.created_at <= ?",supplier,from,to).order(:created_at)
     elsif supplier.blank?
        @supplier_prices_report = PurchasePrice.joins(:supplier).where("purchase_prices.created_at >= ? AND purchase_prices.created_at <= ?",from,to).order(:created_at)
      end

      # Setup filename
      title = t("activerecord.models.supplier.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@supplier_prices_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data PurchasePrice.to_csv(@supplier_prices_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_purchase_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    #
    # Default Methods
    #
    def index
      project = params[:Project]
      client = params[:Supplier]
      subscriber = params[:Subscriber]
      order = params[:Order]
      account = params[:Account]

      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end

      @project = !project.blank? ? Project.find(project).full_name : " "
      @client = !client.blank? ? Client.find(client).full_name : " "
      @subscriber = !subscriber.blank? ? Subscriber.find(subscriber).full_name : " "
      @work_order = !order.blank? ? WorkOrder.find(order).full_name : " "
      @charge_account = !account.blank? ? ChargeAccount.find(account).full_name : " "

      @statuses = OrderStatus.order('id')
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.water_supply_contract.few")
      _array = _array << t("activerecord.models.water_connection_contract.few")
      _array = _array << t("activerecord.models.contracting_request.few")
      _array = _array << t("activerecord.models.pre_invoice.few")
      _array = _array << t("activerecord.models.invoice.few")
      _array = _array << t("activerecord.models.invoice.pending")
      _array = _array << t("activerecord.models.client_payment.few")
      _array = _array << t("activerecord.models.debt_claim.few")
      _array = _array << t("activerecord.models.pre_reading.few")
      _array = _array << t("activerecord.models.reading.few")
      _array = _array << t("activerecord.models.meter.few")
      _array = _array << t("activerecord.models.service_point.few")
      _array = _array << t("activerecord.models.subscriber.few")
      _array = _array << t("activerecord.models.client.few")
      _array
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def suppliers_dropdown
      session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    # Stores belonging to current project
    def project_stores(_project)
      _array = []
      _stores = nil

      # Adding global stores, not JIT, belonging to current project's company
      if !_project.company.blank?
        _stores = Store.where("company_id = ? AND office_id IS NULL AND supplier_id IS NULL", _project.company_id)
      elsif session[:company] != '0'
        _stores = Store.where("company_id = ? AND office_id IS NULL AND supplier_id IS NULL", session[:company].to_i)
      else
        _stores = session[:organization] != '0' ? Store.where("organization_id = ? AND office_id IS NULL AND supplier_id IS NULL", session[:organization].to_i) : Store.all
      end
      ret_array(_array, _stores)
      # Adding stores belonging to current project
      if !_project.company.blank? && !_project.office.blank?
        _stores = Store.where("(company_id = ? AND office_id = ?)", _project.company.id, _project.office.id)
      elsif !_project.company.blank? && _project.office.blank?
        _stores = Store.where("(company_id = ?)", _project.company.id)
      elsif _project.company.blank? && !_project.office.blank?
        _stores = Store.where("(office_id = ?)", _project.office.id)
      else
        _stores = stores_dropdown
      end
      ret_array(_array, _stores)
      # Adding JIT stores
      _ret = session[:organization] != '0' ? Store.where("organization_id = ? AND company_id IS NULL AND NOT supplier_id IS NULL", session[:organization].to_i) : Store.where("(company_id IS NULL AND NOT supplier_id IS NULL)")
      ret_array(_array, _ret)
      # Returning founded stores
      _stores = Store.where(id: _array).order(:name)
    end

    # Stores belonging to projects
    def projects_stores(_projects)
      _array = []
      _ret = nil

      # Adding global stores, not JIT, belonging to current company
      if session[:company] != '0'
        _ret = Store.where("company_id = ? AND office_id IS NULL AND supplier_id IS NULL", session[:company].to_i)
      else
        _ret = session[:organization] != '0' ? Store.where("organization_id = ? AND office_id IS NULL AND supplier_id IS NULL", session[:organization].to_i) : Store.all
      end
      ret_array(_array, _ret)

      # Adding stores belonging to current projects (projects have company and office)
      _projects.each do |i|
        if !i.company.blank? && !i.office.blank?
          _ret = Store.where("(company_id = ? AND office_id = ?)", i.company_id, i.office_id)
        elsif !i.company.blank? && i.office.blank?
          _ret = Store.where("(company_id = ?)", i.company_id)
        elsif i.company.blank? && !i.office.blank?
          _ret = Store.where("(office_id = ?)", i.office_id)
        end
        ret_array(_array, _ret)
      end

      # Adding JIT stores
      _ret = session[:organization] != '0' ? Store.where("organization_id = ? AND company_id IS NULL AND NOT supplier_id IS NULL", session[:organization].to_i) : Store.where("(company_id IS NULL AND NOT supplier_id IS NULL)")
      ret_array(_array, _ret)

      # Returning founded stores
      _ret = Store.where(id: _array).order(:name)
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    # Work orders belonging to projects
    def projects_work_orders(_projects)
      _array = []
      _ret = nil

      # Adding work orders belonging to current projects
      _ret = WorkOrder.where(project_id: _projects)
      ret_array(_array, _ret)
      # _projects.each do |i|
      #   _ret = WorkOrder.where(project_id: i.id)
      #   ret_array(_array, _ret)
      # end

      # Returning founded work orders
      _ret = WorkOrder.where(id: _array).order(:order_no)
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.where('project_id = ? OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _ret = ChargeAccount.where(project_id: _projects)
      ret_array(_array, _ret)
      # _projects.each do |i|
      #   _ret = ChargeAccount.where(project_id: i.id)
      #   ret_array(_array, _ret)
      # end

      # Adding global charge accounts
      _ret = ChargeAccount.where('project_id IS NULL')
      ret_array(_array, _ret)

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
    end

    def families_dropdown
      session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end

    def products_array(_products)
      _array = []
      _products.each do |i|
        _array = _array << [i.id, i.full_code, i.main_description[0,40]]
      end
      _array
    end

    def ret_array(_array, _ret)
      _ret.each do |_r|
        _array = _array << _r.id unless _array.include? _r.id
      end
    end
  end
end
