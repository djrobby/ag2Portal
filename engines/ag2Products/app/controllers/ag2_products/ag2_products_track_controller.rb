require_dependency "ag2_products/application_controller"

module Ag2Products
  class Ag2ProductsTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:inventory_report,
                                               :order_report,
                                               :receipt_report,
                                               :delivery_report,
                                               :stock_report,
                                               :pr_track_project_has_changed,
                                               :pr_track_family_has_changed]

    # Update work order, charge account and store select fields at view from project select
    def pr_track_project_has_changed
      project = params[:order]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? projects_work_orders(projects) : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project.id)
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
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      family = params[:family]
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
      title = t("activerecord.models.inventory_count.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
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
      title = t("activerecord.models.purchase_order.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
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

      # Search necessary data
      #@worker = Worker.find(worker)
      
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.receipt_note.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
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

      # Search necessary data
      #@worker = Worker.find(worker)
      
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.delivery_note.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
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
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      store = params[:store]
      family = params[:family]
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
      title = t("activerecord.models.stock.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
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
      #_array = _array << t("activerecord.models.product.few")
      _array = _array << t("activerecord.models.stock.few")
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
      # Adding stores belonging to current project and JIT stores
      if !_project.company.blank? && !_project.office.blank?
        _stores = Store.where("(company_id = ? AND office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id, _project.office.id).order(:name)
      elsif !_project.company.blank? && _project.office.blank?
        _stores = Store.where("(company_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id).order(:name)
      elsif _project.company.blank? && !_project.office.blank?
        _stores = Store.where("(office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.office.id).order(:name)
      else
        _stores = stores_dropdown
      end
      ret_array(_array, _stores)
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
      _ret = Store.where("(company_id IS NULL AND NOT supplier_id IS NULL)")
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
      _accounts = ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
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
