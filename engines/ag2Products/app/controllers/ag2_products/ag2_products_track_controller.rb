require_dependency "ag2_products/application_controller"

module Ag2Products
  class Ag2ProductsTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:inventory_report,
                                               :order_report,
                                               :receipt_report,
                                               :delivery_report,
                                               :product_items_report,
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

      @inventory_csv = []
      @inventory_report.each do |pr|
        @inventory_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: InventoryCount.to_csv(@inventory_csv) }
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

      @inventory_items_csv = []
      @inventory_items_report.each do |pr|
        @inventory_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: InventoryCountItem.to_csv(@inventory_items_csv) }
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
      petitioner = params[:petitioner]

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

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND created_by = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,status,petitioner,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND order_date >= ? AND order_date <= ?",project,from,to).order(:order_no)


      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND order_date >= ? AND order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,store,status,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND store_id = ? AND created_by = ? AND order_date >= ? AND order_date <= ?",project,store,petitioner,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND supplier_id = ? AND order_date >= ? AND order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND order_status_id = ? AND created_by = ? AND order_date >= ? AND order_date <= ?",project,order,account,status,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND work_order_id = ? AND order_date >= ? AND order_date <= ?",project,order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND charge_account_id = ? AND order_date >= ? AND order_date <= ?",project,account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND order_status_id = ? AND order_date >= ? AND order_date <= ?",project,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND created_by = ? AND order_date >= ? AND order_date <= ?",project,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.where("project_id in (?) AND order_date >= ? AND order_date <= ?",project,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      @order_csv = []
      @order_report.each do |pr|
        @order_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: PurchaseOrder.to_csv(@order_csv) }
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
      petitioner = params[:petitioner]

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

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,petitioner,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,status,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,petitioner,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,project,order,account,status,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      @order_items_csv = []
      @order_items_report.each do |pr|
        @order_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: PurchaseOrderItem.to_csv(@order_items_csv) }
      end
    end

    # Purchase orders pending balance report
    def order_pending_report
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
      petitioner = params[:petitioner]

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

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,store,order,account,status,petitioner,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.store_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.store_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,status,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.store_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,petitioner,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",order,account,status,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_report = PurchaseOrder.pending_balance(project).where("purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",petitioner,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      @order_csv  = []
      @order_report.each do |pr|
        @order_csv  << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: PurchaseOrder.to_csv(@order_csv) }
      end
    end

    # Orders pending Items report
    def order_pending_items_report
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
      petitioner = params[:petitioner]

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

      if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,petitioner,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,status,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,account,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,order,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,store,from,to).order(:order_no)
      elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,from,to).order(:order_no)

      elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,order,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,account,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,status,from,to).order(:order_no)
      elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.store_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,store,petitioner,from,to).order(:order_no)

      elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.supplier_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,supplier,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,account,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank? && !status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.charge_account_id = ? AND purchase_orders.order_status_id = ? AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,account,status,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.work_order_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,order,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.charge_account_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,account,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && !status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.order_status_id = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,status,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && !petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.created_by = ? AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,petitioner,from,to).order(:order_no)
      elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank? && status.blank? && petitioner.blank?
        @order_items_report = PurchaseOrderItem.joins(:purchase_order => :purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",project,from,to).order(:order_no)
      end

      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"

      @order_items_csv = []
      @order_items_report.each do |pr|
        @order_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: PurchaseOrderItem.to_csv(@order_items_csv) }
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
      balance = params[:balance]
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

      if balance == '0'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND rreceipt_notes.eceipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)


        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_total.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      elsif balance == '1'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND .receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND rreceipt_notes.eceipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)


        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_partial.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      elsif balance == '2'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND rreceipt_notes.eceipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)


        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.bill_unbilled.where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      else
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND supplier_id = ? AND store_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND supplier_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND receipt_date >= ? AND receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND store_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,store,account,from,to).order(:receipt_no)


        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND supplier_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND work_order_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.where("project_id in (?) AND charge_account_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_report = ReceiptNote.where("project_id = ? AND receipt_date >= ? AND receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      end

      # Setup filename
      title = t("activerecord.models.receipt_note.few") + "_#{from}_#{to}.pdf"

      @receipt_csv = []
      @receipt_report.each do |pr|
        @receipt_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: ReceiptNote.to_csv(@receipt_csv) }
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
      balance = params[:balance]
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

      if balance == '0'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)

        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_total.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      elsif balance == '1'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)

        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_partial.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      elsif balance == '2'
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)

        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.bill_unbilled.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      else
        if !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,account,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,store,from,to).order(:receipt_no)
        elsif !project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,from,to).order(:receipt_no)

        elsif !project.blank? && supplier.blank? && !store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,order,from,to).order(:receipt_no)
        elsif !project.blank? && supplier.blank? && !store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.store_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,store,account,from,to).order(:receipt_no)

        elsif project.blank? && !supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.supplier_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,supplier,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && !order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.work_order_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,order,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && !account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,account,from,to).order(:receipt_no)
        elsif project.blank? && supplier.blank? && store.blank? && order.blank? && account.blank?
          @receipt_items_report = ReceiptNoteItem.joins(:receipt_note).where("receipt_notes.charge_account_id = ? AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",project,from,to).order(:receipt_no)
        end
      end

      # Setup filename
      title = t("activerecord.models.receipt_note.few") + "_#{from}_#{to}.pdf"

      @receipt_items_csv = []
      @receipt_items_report.each do |pr|
        @receipt_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: ReceiptNoteItem.to_csv(@receipt_items_csv) }
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
        @delivery_report = DeliveryNote.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,order,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND store_id = ? AND work_order_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,order,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND store_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND store_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,store,from,to).order(:delivery_no)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND delivery_date >= ? AND delivery_date <= ?",project,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND work_order_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,order,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && !account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND work_order_id = ? AND charge_account_id = ? AND delivery_date >= ? AND delivery_date <= ?",project,order,account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_report = DeliveryNote.where("project_id in (?) AND delivery_date >= ? AND delivery_date <= ?",project,from,to).order(:delivery_no)
      end

      # Setup filename
      title = t("activerecord.models.delivery_note.few") + "_#{from}_#{to}.pdf"

      @delivery_csv = []
      @delivery_report.each do |pr|
        @delivery_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: DeliveryNote.to_csv(@delivery_csv) }
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
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.store_id = ? AND delivery_notes.work_order_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,order,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && !order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.store_id = ? AND delivery_notes.work_order_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,order,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.store_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,account,from,to).order(:delivery_no)
      elsif !project.blank? && !store.blank? && order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.store_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,store,from,to).order(:delivery_no)
      elsif !project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.work_order_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,order,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && !order.blank? && !account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_notes.work_order_id = ? AND delivery_notes.charge_account_id = ? AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,order,account,from,to).order(:delivery_no)
      elsif project.blank? && store.blank? && order.blank? && account.blank?
        @delivery_items_report = DeliveryNoteItem.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",project,from,to).order(:delivery_no)
      end

      # Setup filename
      title = t("activerecord.models.delivery_note.few") + "_#{from}_#{to}.pdf"

      @delivery_items_csv = []
      @delivery_items_report.each do |pr|
        @delivery_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: DeliveryNoteItem.to_csv(@delivery_items_csv) }
      end
    end

    # product report
    def product_items_report
      detailed = params[:detailed]  # Not used!
      store = params[:store]
      family = params[:family]

      # Dates are mandatory
      from = Date.today.to_s
      # if @from.blank? || @to.blank?
      #   return
      # end

      # Format dates (must use to only!)
      # from = Time.parse(@from).strftime("%Y-%m-%d")
      # to = Time.parse(@to).strftime("%Y-%m-%d")

      if !family.blank?
        @product_items_report = Product.where("product_family_id = ?",family).order(:product_family_id)
      elsif family.blank?
        @product_items_report = Product.order(:product_family_id)
      end

      # Setup filename
      title = t("activerecord.models.product.few" + "_#{from}")

      @product_items_csv = []
      @product_items_report.each do |pr|
        @product_items_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: Product.to_csv(@product_items_csv) }
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
      if detailed == "false"
        if !product.blank?  # By Product: In one store or in every stores
          @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store_product_stock(store, product) : ProductValuedStock.belongs_to_product_stock(product)
        else
          if !family.blank?   # By Family: In one store on in every stores
            @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store_family_stock(store, family) : ProductValuedStock.belongs_to_family_stock(family)
          else
            # By Store: In one store on in every stores
            @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store_stock(store) : ProductValuedStock.ordered_by_store_family
          end
        end
      else
        if !product.blank?  # By Product: In one store or in every stores
          @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store_product(store, product) : ProductValuedStock.belongs_to_product(product)
        else
          if !family.blank?   # By Family: In one store on in every stores
            @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store_family(store, family) : ProductValuedStock.belongs_to_family(family)
          else
            # By Store: In one store on in every stores
            @stocks_report = !store.blank? ? ProductValuedStock.belongs_to_store(store) : ProductValuedStock.ordered_by_store_family
          end
        end
      end

      # if !store.blank? && !family.blank? && !product.blank?
      #  @stocks_report = ProductValuedStock.where("store_id = ? AND product_family_id = ? AND product_id",store,family,product).order(:store_id, :product_family_id)
      # elsif !store.blank? && !family.blank? && product.blank?
      #  @stocks_report = ProductValuedStock.where("store_id = ? AND product_family_id = ?",store,family).order(:store_id, :product_family_id)
      # elsif !store.blank? && family.blank? && product.blank?
      #  @stocks_report = ProductValuedStock.where("store_id = ?",store).order(:store_id, :product_family_id)
      # elsif !store.blank? && family.blank? && !product.blank?
      #  @stocks_report = ProductValuedStock.where("store_id = ? AND product_id = ?",store,product).order(:store_id, :product_family_id)
      # elsif store.blank? && !family.blank? && product.blank?
      #  @stocks_report = ProductValuedStock.where("product_family_id = ?",family).order(:store_id, :product_family_id)
      # elsif store.blank? && !family.blank? && !product.blank?
      #  @stocks_report = ProductValuedStock.where("product_family_id = ? AND product_id = ?",family,product).order(:store_id, :product_family_id)
      # end

      # Setup filename
      title = t("activerecord.models.stock.few") + "_#{from}"

      @stocks_csv = []
      @stocks_report.each do |pr|
        @stocks_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: ProductValuedStock.to_csv(@stocks_csv) }
      end
    end

    # Stock Companies report
    def stock_companies_report
      detailed = params[:detailed]
      store = params[:store]
      family = params[:family]
      product = params[:product]
      company = nil
      if session[:company] != '0'
        company = Company.find(session[:company].to_i) rescue nil
      elsif !store.blank?
        company = Store.find(store).company rescue nil
      end

      # Dates are mandatory
      from = Date.today.to_s
      # if @from.blank? || @to.blank?
      #   return
      # end

      # Format dates (must use to only!)
      # from = Time.parse(@from).strftime("%Y-%m-%d")
      # to = Time.parse(@to).strftime("%Y-%m-%d")

      # Setup instance variable for report
      if detailed == "false"
        if company != nil
          if !product.blank?  # By Product: In one store or in every stores
            @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store_product_stock(company, store, product) : ProductValuedStockByCompany.belongs_to_company_product_stock(company, product)
          else
            if !family.blank?   # By Family: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store_family_stock(company, store, family) : ProductValuedStockByCompany.belongs_to_company_family_stock(company, family)
            else
              # By Store: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store_stock(company, store) : ProductValuedStockByCompany.belongs_to_company_stock(company)
            end
          end
        else
          if !product.blank?  # By Product: In one store or in every stores
            @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store_product_stock(store, product) : ProductValuedStockByCompany.belongs_to_product_stock(product)
          else
            if !family.blank?   # By Family: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store_family_stock(store, family) : ProductValuedStockByCompany.belongs_to_family_stock(family)
            else
              # By Store: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store_stock(store) : ProductValuedStockByCompany.ordered_by_store_family
            end
          end
        end
      else
        if company != nil
          if !product.blank?  # By Product: In one store or in every stores
            @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store_product(company, store, product) : ProductValuedStockByCompany.belongs_to_company_product(company, product)
          else
            if !family.blank?   # By Family: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store_family(company, store, family) : ProductValuedStockByCompany.belongs_to_company_family(company, family)
            else
              # By Store: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_company_store(company, store) : ProductValuedStockByCompany.belongs_to_company(company)
            end
          end
        else
          if !product.blank?  # By Product: In one store or in every stores
            @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store_product(store, product) : ProductValuedStockByCompany.belongs_to_product(product)
          else
            if !family.blank?   # By Family: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store_family(store, family) : ProductValuedStockByCompany.belongs_to_family(family)
            else
              # By Store: In one store on in every stores
              @stocks_report = !store.blank? ? ProductValuedStockByCompany.belongs_to_store(store) : ProductValuedStockByCompany.ordered_by_store_family
            end
          end
        end
      end

      # if !store.blank? && !family.blank? && !product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_family_id = ? AND product_id",store,family,product).order(:store_id, :product_family_id)
      # elsif !store.blank? && !family.blank? && product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_family_id = ?",store,family).order(:store_id, :product_family_id)
      # elsif !store.blank? && family.blank? && product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("store_id = ?",store).order(:store_id, :product_family_id)
      # elsif !store.blank? && family.blank? && !product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("store_id = ? AND product_id = ?",store,product).order(:store_id, :product_family_id)
      # elsif store.blank? && !family.blank? && product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("product_family_id = ?",family).order(:store_id, :product_family_id)
      # elsif store.blank? && !family.blank? && !product.blank?
      #  @stock_companies_report = ProductValuedStockByCompany.where("product_family_id = ? AND product_id = ?",family,product).order(:store_id, :product_family_id)
      # end

      #@stock_companies_report = ProductValuedStockByCompany.joins(:store).where("product_valued_stock_by_companies.company_id = stores.company_id AND project_id in (?) AND store_id = ? AND product_family_id = ? AND product_id = ?",project,store,family,product).order(:store_id, :product_family_id)

      # Setup filename
      title = t("activerecord.models.stock.few") + "_#{from}"

      @stocks_csv = []
      @stocks_report.each do |pr|
        @stocks_csv << pr
      end

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { render text: ProductValuedStockByCompany.to_csv(@stocks_csv) }
      end
    end

    #
    # Default Methods
    #
    def index
      project = params[:Project]
      supplier = params[:Supplier]
      store = params[:Store]
      order = params[:Order]
      account = params[:Account]
      user = params[:User]
      family = params[:Family]
      product = params[:Product]

      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end

      @project = !project.blank? ? Project.find(project).full_name : " "
      @supplier = !supplier.blank? ? Supplier.find(supplier).full_name : " "
      @store = !store.blank? ? Store.find(store).name : " "
      @work_order = !order.blank? ? WorkOrder.find(order).full_name : " "
      @charge_account = !account.blank? ? ChargeAccount.find(account).full_name : " "
      @user = !user.blank? ? User.find(user).to_label : " "
      @family = !family.blank? ? ProductFamily.find(family).full_name : " "
      @product = !product.blank? ? Product.find(product).full_name : " "

      # @projects = projects_dropdown
      # @suppliers = suppliers_dropdown
      # @stores = projects_stores(@projects)
      # @work_orders = projects_work_orders(@projects)
      # @charge_accounts = projects_charge_accounts(@projects)
      @statuses = OrderStatus.order('id')
      # @petitioners = User.order('id')
      # @families = families_dropdown
      # @products = products_dropdown
      @balances = balances_dropdown if @balances.nil?
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.inventory_count.few")
      _array = _array << t("activerecord.models.purchase_order.few")
      _array = _array << t("activerecord.models.purchase_order.pending")
      _array = _array << t("activerecord.models.receipt_note.few")
      _array = _array << t("activerecord.models.delivery_note.few")
      _array = _array << t("activerecord.models.product.few")
      _array = _array << t("ag2_products.ag2_products_track.stock_report.report_title")
      _array = _array << t("ag2_products.ag2_products_track.stock_company_report.report_title")
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
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def balances_dropdown
      _array = []
      _array = _array << [I18n.t("activerecord.attributes.receipt_note.billing_status_total"), 0]
      _array = _array << [I18n.t("activerecord.attributes.receipt_note.billing_status_partial"), 1]
      _array = _array << [I18n.t("activerecord.attributes.receipt_note.billing_status_unreceived"), 2]
      _array
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
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id in (?) OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
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
