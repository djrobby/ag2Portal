require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class Ag2PurchaseTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:request_report,
                                               :offer_report,
                                               :order_report,
                                               :invoice_report,
                                               :payment_report,
                                               :supplier_report,
                                               :pu_track_project_has_changed,
                                               :pu_track_family_has_changed]

    # Update work order, charge account and store select fields at view from project select
    def pu_track_project_has_changed
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
    def pu_track_family_has_changed
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

    # Offer request report
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

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.offer_request.few") + "_#{from}_#{to}"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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

      # Search necessary data
      #@worker = Worker.find(worker)

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.offer.few") + "_#{from}_#{to}"

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

      # Search necessary data
      #@worker = Worker.find(worker)

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.supplier_invoice.few") + "_#{from}_#{to}"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Supplier payments report
    def payment_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      supplier = params[:supplier]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.supplier_payment.few") + "_#{from}_#{to}"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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
        @supplier_report = Supplier.joins(:supplier_invoices).where("supplier_invoices.project_id = ? AND suppliers.id = ?", project, supplier).order("suppliers.supplier_code")
      elsif project.blank? && !supplier.blank?
        @supplier_report = Supplier.where("id = ?", supplier).order(:supplier_code)
      elsif !project.blank? && supplier.blank?
        @supplier_report = Supplier.joins(:supplier_invoices).where("supplier_invoices.project_id = ?", project).order("suppliers.supplier_code")
      elsif project.blank? && supplier.blank?
        @supplier_report = Supplier.order(:supplier_code)
      end

      # Setup filename
      title = t("activerecord.models.supplier.few") + "_#{from}"

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { send_data Supplier.to_csv(@supplier_report),
                     filename: "#{title}.csv",
                     type: 'application/csv',
                     disposition: 'inline' }
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
      @product = !product.blank? ? Product.find(product).full_name : " "

      @statuses = OrderStatus.order('id')
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.offer_request.few")
      _array = _array << t("activerecord.models.offer.few")
      _array = _array << t("activerecord.models.purchase_order.few")
      _array = _array << t("activerecord.models.supplier_invoice.few")
      _array = _array << t("activerecord.models.supplier_payment.few")
      _array = _array << t("activerecord.models.supplier.few")
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
