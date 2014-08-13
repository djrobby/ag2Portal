require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:wo_update_account_textfield_from_project,
                                               :wo_update_worker_select_from_area,
                                               :wo_update_petitioner_textfield_from_client,
                                               :wo_item_totals,
                                               :wo_worker_totals,
                                               :wo_update_description_prices_from_product,
                                               :wo_update_costs_from_worker,
                                               :wo_update_amount_and_costs_from_price_or_quantity,
                                               :wo_update_costs_from_cost_or_hours,
                                               :wo_update_project_textfields_from_organization,
                                               :wo_generate_code]
    # Calculate and format item totals properly
    def wo_item_totals
      qty = params[:qty].to_f / 10000
      amount = params[:amount].to_f / 10000
      costs = params[:costs].to_f / 10000
      tax = params[:tax].to_f / 10000
      # Taxable
      taxable = amount
      # Total
      total = taxable + tax      
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      taxable = number_with_precision(taxable.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "costs" => costs.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "taxable" => taxable.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Calculate and format worker totals properly
    def wo_worker_totals
      hours = params[:hours].to_f / 10000
      costs = params[:costs].to_f / 10000
      count = params[:count].to_i
      # Hours average
      average = count > 0 ? hours / count : 0
      # Total
      total = costs      
      # Format output values
      hours = number_with_precision(hours.round(4), precision: 4)
      average = number_with_precision(average.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "hours" => hours.to_s, "average" => average.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def wo_update_description_prices_from_product
      product = params[:product]
      store = params[:store]
      description = ""
      qty = 0
      cost = 0
      costs = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      current_stock = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        cost = @product.reference_price
        costs = qty * cost
        price = @product.sell_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description,
                     "cost" => cost.to_s, "costs" => costs.to_s,
                     "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }

      respond_to do |format|
        format.html # wo_update_description_prices_from_product.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update cost text fields at view from worker select
    def wo_update_costs_from_worker
      worker = params[:worker]
      project = params[:project]
      year = params[:year].to_i
      hours = params[:hours].to_f / 10000
      cost = 0
      costs = 0
      worker_item = nil
      worker_salary = nil
      hours_year = 2080
      
      if worker != '0' && project != '0'
        @worker = Worker.find(worker) rescue nil
        @project = Project.find(project) rescue nil
        # Look for working day percentage and calculate cost per hour
        if !@worker.nil? && !@project.nil?
          if !@project.company.blank? && !@project.office.blank?  # Company & office
            worker_item = WorkerItem.where(worker_id: @worker, company_id: @project.company, office_id: @project.office).first
          elsif !@project.company.blank? && @project.office.blank?  # Company
            worker_item = WorkerItem.where(worker_id: @worker, company_id: @project.company).first
          elsif @project.company.blank? && !@project.office.blank?  # Office
            worker_item = WorkerItem.where(worker_id: @worker, company_id: @project.office).first
          else  # Neither company nor office
            worker_item = WorkerItem.where(worker_id: @worker).first
          end
          if !worker_item.nil?
            hours_year = worker_item.collective_agreement.hours rescue 2080
            if hours_year.blank?
              hours_year = 2080
            end
            worker_salary = WorkerSalary.where(worker_item_id: worker_item, year: year).first
            if !worker_salary.nil?
              # One year = 2080 hours
              cost = (worker_salary.total_cost / hours_year) * (worker_salary.day_pct / 100)
            end
          end
        end
      end
      # Assignment
      costs = hours * cost
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s }

      respond_to do |format|
        format.html # wo_update_costs_from_worker.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update amount and costs text fields at view (quantity or price changed)
    def wo_update_amount_and_costs_from_price_or_quantity
      cost = params[:cost].to_f / 10000
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      product = params[:product]
      if tax_type.blank? || tax_type == "0"
        if !product.blank? && product != "0"
          tax_type = Product.find(product).tax_type.id
        else
          tax_type = TaxType.where('expiration IS NULL').order('id').first.id
        end
      end
      tax = TaxType.find(tax_type).tax
      amount = qty * price
      costs = qty * cost
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s, 
                     "price" => price.to_s, "amount" => amount.to_s, 
                     "tax" => tax.to_s }

      respond_to do |format|
        format.html # wo_update_amount_and_costs_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update costs text field at view (hours or cost changed)
    def wo_update_costs_from_cost_or_hours
      cost = params[:cost].to_f / 10000
      hours = params[:hours].to_f / 10000
      costs = hours * cost
      hours = number_with_precision(hours.round(4), precision: 4)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "hours" => hours.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s } 

      respond_to do |format|
        format.html # wo_update_costs_from_cost_or_hours.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end
    
    # Update account text field at view from project select
    def wo_update_account_textfield_from_project
      project = params[:id]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? charge_accounts_dropdown : @project.charge_accounts.order(:account_code)
        @store = project_stores(@project)
        @worker = project_workers(@project)
      else
        @charge_account = charge_accounts_dropdown
        @store = stores_dropdown
        @worker = workers_dropdown
      end
      @json_data = { "charge_account" => @charge_account, "store" => @store, "worker" => @worker }

      respond_to do |format|
        format.html # wo_update_account_textfield_from_project.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update in charge (worker) select at view from area select
    def wo_update_worker_select_from_area
      area = params[:id]
      @worker = nil
      if area != '0'
        @area = Area.find(area)
        @worker = @area.worker
      end

      respond_to do |format|
        format.html # wo_update_worker_select_from_area.html.erb does not exist! JSON only
        format.json { render json: @worker }
      end
    end

    # Update petitioner text field at view from client select
    def wo_update_petitioner_textfield_from_client
      client = params[:id]
      @json_data = { "name" => '' }
      if client != '0'
        @client = Client.find(client)
        @json_data = { "name" => @client.name }
      end

      respond_to do |format|
        format.html # wo_update_petitioner_textfield_from_client.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update project text fields at view from organization select
    def wo_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @types = @organization.blank? ? work_order_types_dropdown : @organization.work_order_types.order(:name)
        @labors = @organization.blank? ? work_order_labors_dropdown : @organization.work_order_labors.order(:name)
      else
        @projects = projects_dropdown
        @types = work_order_types_dropdown
        @labors = work_order_labors_dropdown
      end
      @json_data = { "projects" => @projects, "types" => @types, "labors" => @labors }
      render json: @json_data
    end

    # Update order number at view (generate_code_btn)
    def wo_generate_no
      project = params[:project]
      year = Time.new.year
      code = ''

      # Builds code, if possible
      project_code = Project.find(project).project_code rescue '$'
      if project == '$' || project_code == '$'
        code = '$err'
      else
        project = project_code.rjust(10, '0')
        year = year.to_s if year.is_a? Fixnum
        year = year.rjust(4, '0')
        last_no = WorkOrder.where("order_no LIKE ?", "#{project}#{year}%").order(:order_no).maximum(:order_no)
        if last_no.nil?
          code = project + year + '000001'
        else
          last_no = last_no[14..19].to_i + 1
          code = project + year + last_no.to_s.rjust(6, '0')
        end
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /work_orders
    # GET /work_orders.json
    def index
      manage_filter_state
      project = params[:Project]
      type = params[:Type]
      status = params[:Status]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @types = work_order_types_dropdown if @types.nil?
      @statuses = WorkOrderStatus.order('id') if @statuses.nil?

      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      @search = WorkOrder.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !project.blank?
          with :project_id, project
        end
        if !type.blank?
          with :work_order_type_id, type
        end
        if !status.blank?
          with :work_order_status_id, status
        end
        order_by :order_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @work_orders = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_orders }
      end
    end
  
    # GET /work_orders/1
    # GET /work_orders/1.json
    def show
      @breadcrumb = 'read'
      @work_order = WorkOrder.find(params[:id])
      @items = @work_order.work_order_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @workers = @work_order.work_order_workers.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order }
      end
    end
  
    # GET /work_orders/new
    # GET /work_orders/new.json
    def new
      @breadcrumb = 'create'
      @work_order = WorkOrder.new
      @projects = projects_dropdown
      @types = work_order_types_dropdown
      @labors = work_order_labors_dropdown
      @charge_accounts = charge_accounts_dropdown
      @workers = workers_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order }
      end
    end
  
    # GET /work_orders/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order = WorkOrder.find(params[:id])
      @projects = projects_dropdown_edit(@work_order.project)
      @types = work_order_types_dropdown_edit(@work_order.work_order_type)
      @labors = work_order_labors_dropdown_edit(@work_order.work_order_labor)

      @charge_accounts = @work_order.project.blank? ? ChargeAccount.order(:account_code) : @work_order.project.charge_accounts.order(:account_code)
      @workers = project_workers(@work_order.project)
    end
  
    # POST /work_orders
    # POST /work_orders.json
    def create
      @breadcrumb = 'create'
      @work_order = WorkOrder.new(params[:work_order])
      @work_order.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order.save
          format.html { redirect_to @work_order, notice: crud_notice('created', @work_order) }
          format.json { render json: @work_order, status: :created, location: @work_order }
        else
          @projects = projects_dropdown
          @types = work_order_types_dropdown
          @labors = work_order_labors_dropdown
          @charge_accounts = charge_accounts_dropdown
          @workers = workers_dropdown
          format.html { render action: "new" }
          format.json { render json: @work_order.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_orders/1
    # PUT /work_orders/1.json
    def update
      @breadcrumb = 'update'
      @work_order = WorkOrder.find(params[:id])
      @work_order.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order.update_attributes(params[:work_order])
          format.html { redirect_to @work_order,
                        notice: (crud_notice('updated', @work_order) + "#{undo_link(@work_order)}").html_safe }
          format.json { head :no_content }
        else
          @charge_accounts = @work_order.project.blank? ? ChargeAccount.order(:account_code) : @work_order.project.charge_accounts.order(:account_code)
          @workers = project_workers(@work_order.project)
          format.html { render action: "edit" }
          format.json { render json: @work_order.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_orders/1
    # DELETE /work_orders/1.json
    def destroy
      @work_order = WorkOrder.find(params[:id])

      respond_to do |format|
        if @work_order_type.destroy
          format.html { redirect_to work_orders_url,
                      notice: (crud_notice('destroyed', @work_order) + "#{undo_link(@work_order)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_orders_url, alert: "#{@work_order.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order.errors, status: :unprocessable_entity }
        end
      end
    end
    
    private
    
    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end
    
    def project_stores(_project)
      if !_project.company.blank? && !_project.office.blank?
        _store = Store.where("company_id = ? AND office_id = ?", _project.company.id, _project.office.id).order(:name)
      elsif !_project.company.blank? && _project.office.blank?
        _store = Store.where("company_id = ?", _project.company.id).order(:name)
      elsif _project.company.blank? && !_project.office.blank?
        _store = Store.where("office_id = ?", _project.office.id).order(:name)
      else
        _store = Store.order(:name)
      end
      _store
    end

    def project_workers(_project)
      if !_project.company.blank? && !_project.office.blank?  # Company & office
        _worker = company_office_workers(_project.company, _project.office)
      elsif !_project.company.blank? && _project.office.blank?  # Company
        _worker = company_workers(_project.company)
      elsif _project.company.blank? && !_project.office.blank?  # Office
        _worker = office_workers(_project.company, _project.office)
      else  # All
        _worker = Worker.order(:last_name, :first_name)
      end
      _worker
    end
    
    def company_office_workers(_company, _office)
      # Company & office
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company, office_id: _office }).order(:last_name, :first_name)
      if _workers.blank?  # If not, office
        _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { office_id: _office }).order(:last_name, :first_name)
        if _workers.blank? # If not, company
          _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:last_name, :first_name)
          if _workers.blank?  # If not, last, all
            _workers = Worker.order(:last_name, :first_name)            
          end
        end
      end
      _workers
    end
    
    def company_workers(_company)
      # Company
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:last_name, :first_name)
      if _workers.blank?  # If not, all
        _workers = Worker.order(:last_name, :first_name)            
      end
      _workers
    end

    def office_workers(_company, _office)
      # Office
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { office_id: _office }).order(:last_name, :first_name)
      if _workers.blank? # If not, company
        _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:last_name, :first_name)
        if _workers.blank?  # If not, last, all
          _workers = Worker.order(:last_name, :first_name)            
        end
      end
      _workers
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

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def work_order_types_dropdown
      _types = session[:organization] != '0' ? WorkOrderType.where(organization_id: session[:organization].to_i).order(:name) : WorkOrderType.order(:name)
    end

    def work_order_types_dropdown_edit(_type)
      _types = work_order_types_dropdown
      if _types.blank?
        _types = WorkOrderType.where(id: _type)
      end
      _types
    end

    def work_order_labors_dropdown
      _labors = session[:organization] != '0' ? WorkOrderLabor.where(organization_id: session[:organization].to_i).order(:name) : WorkOrderLabor.order(:name)
    end

    def work_order_labors_dropdown_edit(_labor)
      _labors = work_order_labors_dropdown
      if _labors.blank?
        _labors = WorkOrderLabor.where(id: _labor)
      end
      _labors
    end

    def charge_accounts_dropdown
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def workers_dropdown
      _workers = session[:organization] != '0' ? Worker.where(organization_id: session[:organization].to_i).order(:last_name, :first_name) : Worker.order(:last_name, :first_name)
    end

    def stores_dropdown
      _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
    end
  end
end
