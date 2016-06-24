require_dependency "ag2_products/application_controller"

module Ag2Products
  class Ag2ProductsTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:inventory_report,
                                               :order_report,
                                               :receipt_report,
                                               :delivery_report,
                                               :stock_report,
                                               :stock_companies_report,
                                               :pr_track_project_has_changed,
                                               :pr_track_family_has_changed]

    # Update work order, charge account and store select fields at view from project select
    def pr_track_project_has_changed
      project = params[:order]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? projects_work_orders(projects) : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        @store = @project.blank? ? projects_stores(projects) : project_stores(@project)
      else
        @work_order = projects_work_orders(projects)
        @charge_account = projects_charge_accounts(projects)
        @store = projects_stores(projects)
      end
      @json_data = { "work_order" => @work_order, "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Update product select fields at view from family select
    def pr_track_family_has_changed
      family = params[:order]
      if family != '0'
        @family = ProductFamily.find(family)
        @products = @family.blank? ? products_dropdown : @family.products.order(:product_code)
      else
        @products = products_dropdown
      end
      # Products array
      @products_dropdown = products_array(@products)
      @json_data = { "product" => @products_dropdown }
      render json: @json_data
    end

    # Inventory counts report
    def inventory_report
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      family = params[:family]
      product = params[:product]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

     from = Time.parse(@from).strftime("%Y-%m-%d")
     to = Time.parse(@to).strftime("%Y-%m-%d")

      if !store.blank? && !family.blank?
        @inventory_report = InventoryCount.where("store_id = ? AND product_family_id = ? AND count_date >= ? AND count_date <= ?",store,family,from,to).order(:count_no)
      elsif store.blank? && !family.blank?
        @inventory_report = InventoryCount.where("product_family_id = ? AND count_date >= ? AND count_date <= ?",family,from,to).order(:count_no)
      elsif !store.blank? && family.blank?
        @inventory_report = InventoryCount.where("store_id = ? AND count_date >= ? AND count_date <= ?",store,from,to).order(:count_no)
      end

      # Setup filename
      title = t("activerecord.models.inventory_count.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Inventory Items report
    def inventory_items_report
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      family = params[:family]
      product = params[:product]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

     from = Time.parse(@from).strftime("%Y-%m-%d")
     to = Time.parse(@to).strftime("%Y-%m-%d")

      if !store.blank? && !family.blank?
        @inventory_items_report = InventoryCountItem.joins(:inventory_count).where("store_id = ? AND product_family_id = ? AND count_date >= ? AND count_date <= ?",store,family,from,to).order(:count_no)
      elsif store.blank? && !family.blank?
        @inventory_items_report = InventoryCountItem.joins(:inventory_count).where("product_family_id = ? AND count_date >= ? AND count_date <= ?",family,from,to).order(:count_no)
      elsif !store.blank? && family.blank?
        @inventory_items_report = InventoryCountItem.joins(:inventory_count).where("store_id = ? AND count_date >= ? AND count_date <= ?",store,from,to).order(:count_no)
      end

      # Setup filename
      title = t("activerecord.models.inventory_count.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND supplier_id = ? AND store_id = ? order_date >= ? AND order_date <= ?",project,supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND supplier_id = ? order_date >= ? AND order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND order_date >= ? AND order_date <= ?",project,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND store_id = ? AND order_date >= ? AND order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND store_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("project_id = ? AND store_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,store,status,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("supplier_id = ? AND order_date >= ? AND order_date <= ?",supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_report = PurchaseOrder.where("work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank?
        @order_report = PurchaseOrder.where("work_order_id = ? AND order_date >= ? AND order_date <= ?",order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank?
        @order_report = PurchaseOrder.where("charge_account_id = ? AND order_date >= ? AND order_date <= ?",account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank?
        @order_items_report = PurchaseOrder.where("order_status_id = ? AND order_date >= ? AND order_date <= ?",status,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.supplier_id = ? purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.store_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,status,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",status,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Receipt notes report
    def receipt_report
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

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND supplier_id = ? AND store_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND supplier_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND store_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,from,to).order(:receipt_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND store_id = ? AND work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
        @receipt_report = ReceiptNote.where("project_id = ? AND store_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,account,from,to).order(:receipt_no)


      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("supplier_id = ? AND receipt_date >= ? AND receipt_date <= ?",supplier,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
        @receipt_report = ReceiptNote.where("work_order_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",order,account,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
        @receipt_report = ReceiptNote.where("work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",order,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
        @receipt_report = ReceiptNote.where("charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",account,from,to).order(:receipt_no)
      end

      # Setup filename
      title = t("activerecord.models.receipt_note.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Receipt notes items report
    def receipt_items_report
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

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,from,to).order(:receipt_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id = ? AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",supplier,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",order,account,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",order,from,to).order(:receipt_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
        @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",account,from,to).order(:receipt_no)
      end

      # Setup filename
      title = t("activerecord.models.receipt_note.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Delivery notes report
    def delivery_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("project_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,order,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id = ? AND store_id = ? AND work_order_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,order,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("project_id = ? AND store_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id = ? AND store_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,from,to).order(:delivery_no)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("work_order_id = ? AND delivery_date >= ? AND delivery_date <= ?",order,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("work_order_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",order,account,from,to).order(:delivery_no)
      end

      # Setup filename
      title = t("activerecord.models.delivery_note.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Delivery notes Items report
    def delivery_items_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      order = params[:order]
      account = params[:account]
      product = params[:product]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? && !store.blank? && !order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id = ? AND delivery_notes.store_id = ? AND delivery_notes.work_order_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,order,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id = ? AND delivery_notes.store_id = ? AND delivery_notes.work_order_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,order,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id = ? AND delivery_notes.store_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id = ? AND delivery_notes.store_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,from,to).order(:delivery_no)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.work_order_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",order,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.delivery_notes.work_order_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",order,account,from,to).order(:delivery_no)
      end

      # Setup filename
      title = t("activerecord.models.delivery_note.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Stock report
    def stock_report
      detailed = params[:detailed]
      store = params[:store]
      family = params[:family]
      product = params[:product]

      # Dates are mandatory
      from = Date.today.to_s
      # if @from.blank? || @to.blank?
      #   return
      # end

      # Format dates (must use to only!)
      # from = Time.parse(@from).strftime("%Y-%m-%d")
      # to = Time.parse(@to).strftime("%Y-%m-%d")

      # Setup instance variable for report
      if !store.blank? && !family.blank? && !product.blank?
       @stocks_report = ProductValuedStock.where("store_id = ? AND product_family_id = ? AND product_id",store,family,product).order(:store_id, :product_family_id)
      elsif !store.blank? && !family.blank? && product.blank?
       @stocks_report = ProductValuedStock.where("store_id = ? AND product_family_id = ?",store,family).order(:store_id, :product_family_id)
      elsif !store.blank? && family.blank? && product.blank?
       @stocks_report = ProductValuedStock.where("store_id = ?",store).order(:store_id, :product_family_id)
      elsif !store.blank? && family.blank? && !product.blank?
       @stocks_report = ProductValuedStock.where("store_id = ? AND product_id = ?",store,product).order(:store_id, :product_family_id)
      elsif store.blank? && !family.blank? && product.blank?
       @stocks_report = ProductValuedStock.where("product_family_id = ?",family).order(:store_id, :product_family_id)
      elsif store.blank? && !family.blank? && !product.blank?
       @stocks_report = ProductValuedStock.where("product_family_id = ? AND product_id = ?",family,product).order(:store_id, :product_family_id)
      end

      # Setup filename
      title = t("activerecord.models.stock.few") + "_#{from}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Stock Companies report
    def stock_companies_report
      detailed = params[:detailed]
      store = params[:store]
      family = params[:family]
      product = params[:product]

      # Dates are mandatory
      from = Date.today.to_s
      # if @from.blank? || @to.blank?
      #   return
      # end

      # Format dates (must use to only!)
      # from = Time.parse(@from).strftime("%Y-%m-%d")
      # to = Time.parse(@to).strftime("%Y-%m-%d")

      # Setup instance variable for report
      if !store.blank? && !family.blank? && !product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_family_id = ? AND product_id",store,family,product).order(:store_id, :product_family_id)
      elsif !store.blank? && !family.blank? && product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_family_id = ?",store,family).order(:store_id, :product_family_id)
      elsif !store.blank? && family.blank? && product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("store_id = ?",store).order(:store_id, :product_family_id)
      elsif !store.blank? && family.blank? && !product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_id = ?",store,product).order(:store_id, :product_family_id)
      elsif store.blank? && !family.blank? && product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("product_family_id = ?",family).order(:store_id, :product_family_id)
      elsif store.blank? && !family.blank? && !product.blank?
       @stock_companies_report = ProductValuedStockByCompany.where("product_family_id = ? AND product_id = ?",family,product).order(:store_id, :product_family_id)
      end

      #@stock_companies_report = ProductValuedStockByCompany.joins(:store).where("product_valued_stock_by_companies.company_id = stores.company_id AND project_id = ? AND store_id = ? AND product_family_id = ? AND product_id = ?",project,store,family,product).order(:store_id, :product_family_id)

      # Setup filename
      title = t("activerecord.models.stock.few") + "_#{from}.pdf"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    #
    # Default Methods
    #
    def index
      #authorize! :update, TimeRecord
      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end

      @projects = projects_dropdown
      @suppliers = suppliers_dropdown
      @stores = projects_stores(@projects)
      @work_orders = projects_work_orders(@projects)
      @charge_accounts = projects_charge_accounts(@projects)
      @statuses = OrderStatus.order('id')
      @families = families_dropdown
      @products = products_dropdown
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.inventory_count.few")
      _array = _array << t("activerecord.models.purchase_order.few")
      _array = _array << t("activerecord.models.receipt_note.few")
      _array = _array << t("activerecord.models.delivery_note.few")
      _array = _array << t("ag2_products.ag2_products_track.stock_report.report_title")
      _array = _array << t("ag2_products.ag2_products_track.stock_company_report.report_title")
      _array
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
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
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
      _orders = session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    # Work orders belonging to projects
    def projects_work_orders(_projects)
      _array = []
      _ret = nil

      # Adding work orders belonging to current projects
      _projects.each do |i|
        _ret = WorkOrder.where(project_id: i.id)
        ret_array(_array, _ret)
      end

      # Returning founded work orders
      _ret = WorkOrder.where(id: _array).order(:order_no)
    end

    def charge_accounts_dropdown
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id = ? OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _projects.each do |i|
        _ret = ChargeAccount.where(project_id: i.id)
        ret_array(_array, _ret)
      end

      # Adding global charge accounts
      _ret = ChargeAccount.where('project_id IS NULL')
      ret_array(_array, _ret)

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
    end

    def families_dropdown
      _families = session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)
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
