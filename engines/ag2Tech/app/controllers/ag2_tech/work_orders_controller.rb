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
                                               :wo_subcontractor_totals,
                                               :wo_tool_totals,
                                               :wo_vehicle_totals,
                                               :wo_update_description_prices_from_product,
                                               :wo_update_costs_from_worker,
                                               :wo_update_amount_and_costs_from_price_or_quantity,
                                               :wo_update_costs_from_cost_or_hours,
                                               :wo_update_project_textfields_from_organization,
                                               :wo_generate_no,
                                               :wo_update_costs_from_tool,
                                               :wo_update_costs_from_vehicle,
                                               :wo_update_costs_from_cost_or_minutes,
                                               :wo_update_costs_from_cost_or_distance,
                                               :wo_update_orders_costs_from_supplier,
                                               :wo_update_costs_from_purchase_order,
                                               :wo_update_costs_from_cost_or_enforcement_pct]
    #
    # Subforms
    #
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

    # Calculate and format subcontractor totals properly
    def wo_subcontractor_totals
      pct = params[:pct].to_f / 100
      costs = params[:costs].to_f / 10000
      count = params[:count].to_i
      # Format output values
      total = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "total" => total.to_s }
      render json: @json_data
    end

    # Calculate and format tool totals properly
    def wo_tool_totals
      minutes = params[:minutes].to_f / 100
      costs = params[:costs].to_f / 10000
      count = params[:count].to_i
      # Minutes average
      average = count > 0 ? minutes / count : 0
      # Total
      total = costs      
      # Format output values
      minutes = number_with_precision(minutes.round(2), precision: 2)
      average = number_with_precision(average.round(2), precision: 2)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "minutes" => minutes.to_s, "average" => average.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Calculate and format vehicle totals properly
    def wo_vehicle_totals
      distance = params[:distance].to_f / 100
      costs = params[:costs].to_f / 10000
      count = params[:count].to_i
      # Minutes average
      average = count > 0 ? distance / count : 0
      # Total
      total = costs      
      # Format output values
      distance = number_with_precision(distance.round(2), precision: 2)
      average = number_with_precision(average.round(2), precision: 2)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "distance" => distance.to_s, "average" => average.to_s, "total" => total.to_s }
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
      render json: @json_data
    end
    
    # Update purchase order select and costs fields at view from supplier select
    def wo_update_orders_costs_from_supplier
      supplier = params[:supplier]
      pct = params[:pct]
      cost = 0
      costs = 0
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @orders = @supplier.blank? ? orders_dropdown : @supplier.purchase_orders.order(:supplier_id, :order_no, :id)
      else
        @orders = orders_dropdown
      end
      # Purchase orders array
      @orders_dropdown = orders_array(@orders)
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "order" => @orders_dropdown }
      render json: @json_data
    end

    # Update cost text fields at view from purchase order select
    def wo_update_costs_from_purchase_order
      order = params[:order]
      pct = params[:pct].to_f / 100
      cost = 0
      costs = 0
      if order != '0'
        @order = PurchaseOrder.find(order)
        # Assignment
        cost = @order.taxable
        costs = pct * cost
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data
    end

    # Update cost text fields at view from tool select
    def wo_update_costs_from_tool
      tool = params[:tool]
      minutes = params[:minutes].to_f / 100
      cost = 0
      costs = 0
      if tool != '0'
        @tool = Tool.find(tool)
        # Assignment
        cost = @tool.cost
        costs = minutes * cost
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data
    end

    # Update cost text fields at view from vehicle select
    def wo_update_costs_from_vehicle
      vehicle = params[:vehicle]
      distance = params[:distance].to_f / 100
      cost = 0
      costs = 0
      if vehicle != '0'
        @vehicle = Vehicle.find(vehicle)
        # Assignment
        cost = @vehicle.cost
        costs = distance * cost
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data
    end

    # Update amount and costs text fields at view -item- (quantity or price changed)
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

    # Update costs text field at view -worker- (hours or cost changed)
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

    # Update costs text field at view -subcontractor- (enforment_pct or cost changed)
    def wo_update_costs_from_cost_or_enforcement_pct
      cost = params[:cost].to_f / 10000
      pct = params[:pct].to_f / 100
      costs = (pct / 100) * cost
      pct = number_with_precision(pct.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "pct" => pct.to_s, "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data 
    end

    # Update costs text field at view -tool- (minutes or cost changed)
    def wo_update_costs_from_cost_or_minutes
      cost = params[:cost].to_f / 10000
      minutes = params[:minutes].to_f / 100
      costs = minutes * cost
      minutes = number_with_precision(minutes.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "minutes" => minutes.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data 
    end

    # Update costs text field at view -vehicle- (distance or cost changed)
    def wo_update_costs_from_cost_or_distance
      cost = params[:cost].to_f / 10000
      distance = params[:distance].to_f / 100
      costs = distance * cost
      distance = number_with_precision(distance.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "distance" => distance.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s }
      render json: @json_data 
    end
    
    #
    # Main form
    #
    # Update account text field at view from project select
    def wo_update_account_textfield_from_project
      project = params[:id]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
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

    # Update project text and other fields at view from organization select
    def wo_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @types = @organization.blank? ? work_order_types_dropdown : @organization.work_order_types.order(:name)
        @labors = @organization.blank? ? work_order_labors_dropdown : @organization.work_order_labors.order(:name)
        @clients = @organization.blank? ? clients_dropdown : @organization.clients.order(:client_code)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @workers = @organization.blank? ? workers_dropdown : @organization.workers.order(:worker_code)
        @areas = @organization.blank? ? areas_dropdown : organization_areas(@organization)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @orders = @organization.blank? ? orders_dropdown : @organization.purchase_orders.order(:supplier_id, :order_no, :id)
        @tools = @organization.blank? ? tools_dropdown : @organization.tools.order(:serial_no)
        @vehicles = @organization.blank? ? vehicles_dropdown : @organization.vehicles.order(:registration)
      else
        @projects = projects_dropdown
        @types = work_order_types_dropdown
        @labors = work_order_labors_dropdown
        @clients = clients_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @workers = workers_dropdown
        @areas = areas_dropdown
        @products = products_dropdown
        @suppliers = suppliers_dropdown
        @orders = orders_dropdown
        @tools = tools_dropdown
        @vehicles = vehicles_dropdown
      end
      @areas_dropdown = []
      @areas.each do |i|
        @areas_dropdown = @areas_dropdown << [i.id, i.name, i.department.name] 
      end
      @json_data = { "project" => @projects, "type" => @types, "labor" => @labors,
                     "client" => @clients, "charge_account" => @charge_accounts,
                     "store" => @stores, "worker" => @workers,
                     "area" => @areas_dropdown, "product" => @products,
                     "supplier" => @suppliers, "order" => @orders,
                     "tool" => @tools, "vehicle" => @vehicles }
      render json: @json_data
    end

    # Update order number at view (generate_code_btn)
    def wo_generate_no
      project = params[:project]

      # Builds no, if possible
      code = project == '$' ? '$err' : wo_next_no(project)
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
      no = params[:No]
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
        if !no.blank?
          with :order_no, no
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
        format.js
      end
    end
  
    # GET /work_orders/1
    # GET /work_orders/1.json
    def show
      @breadcrumb = 'read'
      @work_order = WorkOrder.find(params[:id])
      @items = @work_order.work_order_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @workers = @work_order.work_order_workers.paginate(:page => params[:page], :per_page => per_page).order('id')
      @subcontractors = @work_order.work_order_subcontractors.paginate(:page => params[:page], :per_page => per_page).order('id')
      @tools = @work_order.work_order_tools.paginate(:page => params[:page], :per_page => per_page).order('id')
      @vehicles = @work_order.work_order_vehicles.paginate(:page => params[:page], :per_page => per_page).order('id')
  
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
      # Form
      @projects = projects_dropdown
      @types = work_order_types_dropdown
      @labors = work_order_labors_dropdown
      @areas = areas_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @clients = clients_dropdown
      # Form & Sub-forms
      @workers = workers_dropdown
      # Sub-forms
      @products = products_dropdown
      @suppliers = suppliers_dropdown
      @orders = orders_dropdown
      @tools = tools_dropdown
      @vehicles = vehicles_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order }
      end
    end
  
    # GET /work_orders/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order = WorkOrder.find(params[:id])
      # Form
      @projects = projects_dropdown_edit(@work_order.project)
      @types = work_order_types_dropdown_edit(@work_order.work_order_type)
      @labors = work_order_labors_dropdown_edit(@work_order.work_order_labor)
      @areas = areas_dropdown
      @charge_accounts = @work_order.project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@work_order.project_id)
      @stores = project_stores(@work_order.project)
      @clients = clients_dropdown
      # Form & Sub-forms
      @workers = project_workers(@work_order.project)
      # Sub-forms
      @products = @work_order.organization.blank? ? products_dropdown : @work_order.organization.products(:product_code)
      @suppliers = @work_order.organization.blank? ? suppliers_dropdown : @work_order.organization.suppliers(:supplier_code)
      @orders = orders_dropdown_edit(@work_order, nil)
      #@orders = @work_order.supplier.blank? ? orders_dropdown : @work_order.supplier.purchase_orders.order(:supplier_id, :order_no, :id)
      @tools = tools_dropdown_edit(@work_order)
      @vehicles = vehicles_dropdown_edit(@work_order)
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
          @areas = areas_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @clients = clients_dropdown
          @workers = workers_dropdown
          @products = products_dropdown
          @suppliers = suppliers_dropdown
          @orders = orders_dropdown
          @tools = tools_dropdown
          @vehicles = vehicles_dropdown
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
          @projects = projects_dropdown_edit(@work_order.project)
          @types = work_order_types_dropdown_edit(@work_order.work_order_type)
          @labors = work_order_labors_dropdown_edit(@work_order.work_order_labor)
          @areas = areas_dropdown
          @charge_accounts = @work_order.project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@work_order.project_id)
          @stores = project_stores(@work_order.project)
          @clients = clients_dropdown
          @workers = project_workers(@work_order.project)
          @products = @work_order.organization.blank? ? products_dropdown : @work_order.organization.products(:product_code)
          @suppliers = @work_order.organization.blank? ? suppliers_dropdown : @work_order.organization.suppliers(:supplier_code)
          @orders = orders_dropdown_edit(@work_order, nil)
          @tools = tools_dropdown_edit(@work_order)
          @vehicles = vehicles_dropdown_edit(@work_order)
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

    # Report
    def work_order_form
      # Search work order & items
      @work_order = WorkOrder.find(params[:id])
      @items = @work_order.work_order_items.order('id')
      @workers = @work_order.work_order_workers.order('id')
      @subcontractors = @work_order.work_order_subcontractors.order('id')
      @tools = @work_order.work_order_tools.order('id')
      @vehicles = @work_order.work_order_vehicles.order('id')

      title = t("activerecord.models.work_order.one")      

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@work_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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
    
    def orders_array(_orders)
      _orders_array = []
      _orders.each do |i|
        _orders_array = _orders_array << [i.id, i.full_no, i.order_date.strftime("%d/%m/%Y"), i.supplier.full_name] 
      end
      _orders_array
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

    def project_workers(_project)
      if !_project.company.blank? && !_project.office.blank?  # Company & office
        _worker = company_office_workers(_project.company, _project.office)
      elsif !_project.company.blank? && _project.office.blank?  # Company
        _worker = company_workers(_project.company)
      elsif _project.company.blank? && !_project.office.blank?  # Office
        _worker = office_workers(_project.company, _project.office)
      else  # All
        _worker = Worker.order(:worker_code)
      end
      _worker
    end
    
    def company_office_workers(_company, _office)
      # Company & office
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company, office_id: _office }).order(:worker_code)
      if _workers.blank?  # If not, office
        _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { office_id: _office }).order(:worker_code)
        if _workers.blank? # If not, company
          _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:worker_code)
          if _workers.blank?  # If not, last, all
            _workers = Worker.order(:worker_code)            
          end
        end
      end
      _workers
    end
    
    def company_workers(_company)
      # Company
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:worker_code)
      if _workers.blank?  # If not, all
        _workers = Worker.order(:worker_code)            
      end
      _workers
    end

    def office_workers(_company, _office)
      # Office
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { office_id: _office }).order(:worker_code)
      if _workers.blank? # If not, company
        _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:worker_code)
        if _workers.blank?  # If not, last, all
          _workers = Worker.order(:worker_code)            
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
      session[:organization] != '0' ? WorkOrderType.where(organization_id: session[:organization].to_i).order(:name) : WorkOrderType.order(:name)
    end

    def work_order_types_dropdown_edit(_type)
      _types = work_order_types_dropdown
      if _types.blank?
        _types = WorkOrderType.where(id: _type)
      end
      _types
    end

    def work_order_labors_dropdown
      session[:organization] != '0' ? WorkOrderLabor.where(organization_id: session[:organization].to_i).order(:name) : WorkOrderLabor.order(:name)
    end

    def work_order_labors_dropdown_edit(_labor)
      _labors = work_order_labors_dropdown
      if _labors.blank?
        _labors = WorkOrderLabor.where(id: _labor)
      end
      _labors
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
    end

    def workers_dropdown
      session[:organization] != '0' ? Worker.where(organization_id: session[:organization].to_i).order(:worker_code) : Worker.order(:worker_code)
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def areas_dropdown
      session[:organization] != '0' ? Area.joins(:department).where(departments: { organization_id: session[:organization].to_i }).order(:name) : Area.order(:name)
    end

    def clients_dropdown
      session[:organization] != '0' ? Client.where(organization_id: session[:organization].to_i).order(:client_code) : Client.order(:client_code)
    end

    def organization_areas(_organization)
      Area.includes(:department).where(departments: { organization_id: _organization })
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end    

    def suppliers_dropdown
      session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def orders_dropdown
      session[:organization] != '0' ? PurchaseOrder.where(organization_id: session[:organization].to_i).order(:supplier_id, :order_no, :id) : PurchaseOrder.order(:supplier_id, :order_no, :id)
    end
    
    def orders_dropdown_edit(_work_order, _supplier)
      _a = nil
      if !_work_order.nil? && !_work_order.project.nil? && !_supplier.nil?
        _a = PurchaseOrder.where('organization_id = ? AND project_id = ? AND supplier_id', _work_order.organization_id, _work_order.project_id, _supplier).order(:supplier_id, :order_no, :id)
      elsif !_work_order.nil? && !_work_order.project.nil? && _supplier.nil?
        _a = PurchaseOrder.where('organization_id = ? AND project_id = ?', _work_order.organization_id, _work_order.project_id).order(:supplier_id, :order_no, :id)
      elsif (_work_order.nil? || _work_order.project.nil?) && !_supplier.nil?
        _a = session[:organization] != '0' ? PurchaseOrder.where('organization_id = ? AND supplier_id = ?', session[:organization].to_i, _supplier).order(:supplier_id, :order_no, :id) : PurchaseOrder.where(supplier_id: _supplier).order(:supplier_id, :order_no, :id)
      else
        _a = orders_dropdown
      end
      _a
    end
    
    def orders_array(_orders)
      _orders_array = []
      _orders.each do |i|
        _orders_array = _orders_array << [i.id, i.full_no, formatted_date(i.order_date), i.supplier.full_name] 
      end
      _orders_array
    end

    def tools_dropdown
      if session[:office] != '0'
        Tool.where('office_id = ? OR (office_id IS NULL AND company_id = ?) OR (office_id IS NULL AND company_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:company].to_i, session[:organization].to_i).order(:serial_no)
      elsif session[:company] != '0'
        Tool.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).order(:serial_no)
      else
        session[:organization] != '0' ? Tool.where(organization_id: session[:organization].to_i).order(:serial_no) : Tool.order(:serial_no)
      end
    end

    def tools_dropdown_edit(_work_order)
      _a = nil
      if !_work_order.nil? && !_work_order.project.nil?
        _a = Tool.where('office_id = ? OR (office_id IS NULL AND company_id = ?) OR (office_id IS NULL AND company_id IS NULL AND organization_id = ?)', _work_order.project.office_id, _work_order.project.company_id, _work_order.organization_id).order(:serial_no)
      else
        _a = tools_dropdown
      end
      _a
    end

    def vehicles_dropdown
      if session[:office] != '0'
        Vehicle.where('office_id = ? OR (office_id IS NULL AND company_id = ?) OR (office_id IS NULL AND company_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:company].to_i, session[:organization].to_i).order(:registration)
      elsif session[:company] != '0'
        Vehicle.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).order(:registration)
      else
        session[:organization] != '0' ? Vehicle.where(organization_id: session[:organization].to_i).order(:registration) : Vehicle.order(:registration)
      end
    end

    def vehicles_dropdown_edit(_work_order)
      _a = nil
      if !_work_order.nil? && !_work_order.project.nil?
        _a = Vehicle.where('office_id = ? OR (office_id IS NULL AND company_id = ?) OR (office_id IS NULL AND company_id IS NULL AND organization_id = ?)', _work_order.project.office_id, _work_order.project.company_id, _work_order.organization_id).order(:registration)
      else
        _a = vehicles_dropdown
      end
      _a
    end
    
    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # no
      if params[:No]
        session[:No] = params[:No]
      elsif session[:No]
        params[:No] = session[:No]
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
