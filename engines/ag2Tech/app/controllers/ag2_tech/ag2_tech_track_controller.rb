require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Ag2TechTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:inventory_report,
                                               :order_report,
                                               :receipt_report,
                                               :delivery_report,
                                               :stock_report,
                                               :te_track_project_has_changed,
                                               :te_track_family_has_changed]

    # Update work order, charge account and store select fields at view from project select
    def pr_track_project_has_changed
      project = params[:order]
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? work_orders_dropdown : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
        @store = project_stores(@project)
      else
        @work_order = work_orders_dropdown
        @charge_account = charge_accounts_dropdown
        @store = stores_dropdown
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

    #
    # Default Methods
    #
    def index
      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end
      
      @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
      @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
      @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
      @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
      @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
      @statuses = OrderStatus.order('id')
      @families = @organization.blank? ? families_dropdown : @organization.product_families.order(:family_code)
      @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
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
    
    def project_stores(_project)
      if !_project.company.blank? && !_project.office.blank?
        _store = Store.where("(company_id = ? AND office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id, _project.office.id).order(:name)
      elsif !_project.company.blank? && _project.office.blank?
        _store = Store.where("(company_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id).order(:name)
      elsif _project.company.blank? && !_project.office.blank?
        _store = Store.where("(office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.office.id).order(:name)
      else
        _store = stores_dropdown
      end
      _store
    end

    def work_orders_dropdown
      _orders = session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def charge_accounts_dropdown
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
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
  end
end
