require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:wo_update_account_textfield_from_project,
                                               :wo_update_worker_select_from_area,
                                               :wo_update_type_select_from_woarea,
                                               :wo_update_labor_select_from_type,
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
                                               :work_order_form,
                                               :work_order_form_sm,
                                               :work_order_form_empty,
                                               :work_order_form_empty_sm,
                                               :work_order_report,
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
      tbl = params[:tbl]
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
        cost = @product.average_price > 0 ? @product.average_price : @product.reference_price
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
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s, "tbl" => tbl.to_s }

      respond_to do |format|
        format.html # wo_update_description_prices_from_product.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update cost text fields at view from worker select
    def wo_update_costs_from_worker
      worker = params[:worker]
      hours = params[:hours].to_f / 10000
      project = params[:project]
      year = params[:year].to_i
      tbl = params[:tbl]
      hours_type = params[:type].to_i
      cost = 0
      costs = 0
      worker_item = nil
      worker_salary = nil
      hours_year = 2080
      overtime_pct = 0

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
          # Overtime hours?
          if hours_type > 0
            # First, by office
            overtime_pct = Office.find(@project.office).overtime_pct rescue 0
            if overtime_pct == 0
              # Then, by company
              overtime_pct = Company.find(@project.company).overtime_pct rescue 0
            end
            # Add overtime to cost
            cost = cost * (1 + (overtime_pct / 100))
          end
        end
      end
      # Assignment
      costs = hours * cost
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update purchase order select and costs fields at view from supplier select
    def wo_update_orders_costs_from_supplier
      supplier = params[:supplier]
      pct = params[:pct]
      tbl = params[:tbl]
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
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "order" => @orders_dropdown, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update cost text fields at view from purchase order select
    def wo_update_costs_from_purchase_order
      order = params[:order]
      pct = params[:pct].to_f / 100
      tbl = params[:tbl]
      cost = 0
      costs = 0
      if order != '0'
        @order = PurchaseOrder.find(order)
        # Assignment
        cost = @order.taxable
        costs = (pct / 100) * cost
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      # Setup JSON
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update cost text fields at view from tool select
    def wo_update_costs_from_tool
      tool = params[:tool]
      minutes = params[:minutes].to_f / 100
      tbl = params[:tbl]
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
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update cost text fields at view from vehicle select
    def wo_update_costs_from_vehicle
      vehicle = params[:vehicle]
      distance = params[:distance].to_f / 100
      tbl = params[:tbl]
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
      @json_data = { "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update amount and costs text fields at view -item- (quantity or price changed)
    def wo_update_amount_and_costs_from_price_or_quantity
      cost = params[:cost].to_f / 10000
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      product = params[:product]
      tbl = params[:tbl]
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
                     "tax" => tax.to_s, "tbl" => tbl.to_s }

      respond_to do |format|
        format.html # wo_update_amount_and_costs_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update costs text field at view -worker- (hours or cost changed)
    def wo_update_costs_from_cost_or_hours
      cost = params[:cost].to_f / 10000
      hours = params[:hours].to_f / 10000
      tbl = params[:tbl]
      costs = hours * cost
      hours = number_with_precision(hours.round(4), precision: 4)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "hours" => hours.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }

      respond_to do |format|
        format.html # wo_update_costs_from_cost_or_hours.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update costs text field at view -subcontractor- (enforment_pct or cost changed)
    def wo_update_costs_from_cost_or_enforcement_pct
      cost = params[:cost].to_f / 10000
      pct = params[:pct].to_f / 100
      tbl = params[:tbl]
      costs = (pct / 100) * cost
      pct = number_with_precision(pct.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "pct" => pct.to_s, "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update costs text field at view -tool- (minutes or cost changed)
    def wo_update_costs_from_cost_or_minutes
      cost = params[:cost].to_f / 10000
      minutes = params[:minutes].to_f / 100
      tbl = params[:tbl]
      costs = minutes * cost
      minutes = number_with_precision(minutes.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "minutes" => minutes.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update costs text field at view -vehicle- (distance or cost changed)
    def wo_update_costs_from_cost_or_distance
      cost = params[:cost].to_f / 10000
      distance = params[:distance].to_f / 100
      tbl = params[:tbl]
      costs = distance * cost
      distance = number_with_precision(distance.round(2), precision: 2)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      @json_data = { "distance" => distance.to_s,
                     "cost" => cost.to_s, "costs" => costs.to_s, "tbl" => tbl.to_s }
      render json: @json_data
    end

    #
    # Main form
    #
    # Update project select, master order select and other fields at view from organization select
    def wo_update_project_textfields_from_organization
      organization = params[:org]
      id = params[:id] != '0' ? params[:id] : nil
      is_new = id.blank? ? true : false
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @woareas = @organization.blank? ? work_order_areas_dropdown : @organization.work_order_areas.order(:name)
        @types = @organization.blank? ? work_order_types_dropdown : @organization.work_order_types.order(:name)
        @labors = @organization.blank? ? work_order_labors_dropdown : @organization.work_order_labors.order(:name)
        @infrastructures = @organization.blank? ? infrastructures_dropdown : @organization.infrastructures.order(:code)
        @clients = @organization.blank? ? clients_dropdown : @organization.clients.order(:client_code)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.expenditures
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @workers = @organization.blank? ? workers_dropdown : @organization.workers.order(:worker_code)
        @areas = @organization.blank? ? areas_dropdown : organization_areas(@organization)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @orders = @organization.blank? ? orders_dropdown : @organization.purchase_orders.order(:supplier_id, :order_no, :id)
        @tools = @organization.blank? ? tools_dropdown : @organization.tools.order(:serial_no)
        @vehicles = @organization.blank? ? vehicles_dropdown : @organization.vehicles.order(:registration)
        @subscribers = @organization.blank? ? subscribers_dropdown : @organization.subscribers.by_code
        @meters = @organization.blank? ? meters_dropdown : @organization.meters.order(:meter_code)
        #@master_order = @organization.blank? ? master_orders_dropdown(nil, nil, id, is_new) : @organization.work_orders.unclosed_only_without_this(nil, id == '0' ? nil : id)
        @master_order = @organization.blank? ? master_orders_dropdown(nil, nil, id, is_new) : master_orders_dropdown(nil, @organization, id, is_new)
      else
        @projects = projects_dropdown
        @woareas = work_order_areas_dropdown
        @types = work_order_types_dropdown
        @labors = work_order_labors_dropdown
        @infrastructures = infrastructures_dropdown
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
        @subscribers = subscribers_dropdown
        @meters = meters_dropdown
        @master_order = master_orders_dropdown(nil, nil, id, is_new)
      end
      # Areas array
      @areas_dropdown = areas_array(@areas)
      # Products array
      @products_dropdown = products_array(@products)
      # Tools array
      @tools_dropdown = tools_array(@tools)
      # Vehicles array
      @vehicles_dropdown = vehicles_array(@vehicles)
      # Work orders array
      @orders_dropdown = orders_array(@master_order)
      # Setup JSON
      @json_data = { "project" => @projects, "woarea" => @woareas,
                     "type" => @types, "labor" => @labors, "infrastructure" => @infrastructures,
                     "client" => @clients, "charge_account" => @charge_accounts,
                     "store" => @stores, "worker" => @workers,
                     "area" => @areas_dropdown, "product" => @products_dropdown,
                     "supplier" => @suppliers, "order" => @orders,
                     "tool" => @tools_dropdown, "vehicle" => @vehicles_dropdown,
                     "subscriber" => @subscribers, "meter" => @meters, "master_order" => @orders_dropdown }
      render json: @json_data
    end

    # Update account & master order selects at view from project select
    def wo_update_account_textfield_from_project
      project = params[:project]
      organization = params[:org] != '0' ? params[:org] : nil
      id = params[:id] != '0' ? params[:id] : nil
      is_new = id.blank? ? true : false
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        @store = project_stores(@project)
        @worker = project_workers(@project)
        @master_order = master_orders_dropdown(@project, organization, id, is_new)
      else
        @charge_account = projects_charge_accounts(projects)
        @store = stores_dropdown
        @worker = workers_dropdown
        @master_order = master_orders_dropdown(nil, organization, id, is_new)
      end
      # Work orders array
      @orders_dropdown = orders_array(@master_order)
      # Setup JSON
      @json_data = { "charge_account" => @charge_account, "store" => @store, "worker" => @worker, "master_order" => @orders_dropdown }
      render json: @json_data
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

    # Update type select at view from woarea select
    def wo_update_type_select_from_woarea
      woarea = params[:woarea]
      if woarea != '0'
        @woarea = WorkOrderArea.find(woarea)
        @types = @woarea.blank? ? work_order_types_dropdown : @woarea.work_order_types.order(:name)
      else
        @types = work_order_types_dropdown
      end
      # Setup JSON
      @json_data = { "type" => @types }
      render json: @json_data
    end

    # Update labor select at view from type select
    def wo_update_labor_select_from_type
      type = params[:type]
      project = params[:project]
      account = nil
      required = 'false'
      if type != '0'
        @type = WorkOrderType.find(type)
        @labors = @type.blank? ? work_order_labors_dropdown : @type.work_order_labors.order(:name)
        account = type_account(@type, project)
        required = @type.subscriber_meter.to_s
      else
        @labors = work_order_labors_dropdown
      end
      # Setup JSON
      @json_data = { "labor" => @labors, "account" => account, "subscriber_meter" => required }
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
    # API (ApiWorkOrdersController)
    #
    # GET /api/work_orders
    def api_work_orders
      @work_orders = WorkOrder.order(:order_no)
      render json: @work_orders
    end

    # GET /api/work_orders_by_project
    def api_work_orders_by_project
      if params.has_key?(:project_id) && params[:project_id] != '0'
        @work_orders = WorkOrder.where(project_id: params[:project_id]).order(:order_no)
        render json: @work_orders
      else
        render json: :bad_request, status: :bad_request
        #render nothing: true, status: :bad_request
      end
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
      area = params[:Area]
      type = params[:Type]
      labor = params[:Labor]
      status = params[:Status]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @areas = work_order_areas_dropdown if @areas.nil?
      @labors = work_order_labors_dropdown if @labors.nil?
      @types = work_order_types_dropdown if @types.nil?
      @statuses = WorkOrderStatus.order('id') if @statuses.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = WorkOrder.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :order_no, no
          else
            with(:order_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !area.blank?
          with :work_order_area_id, area
        end
        if !type.blank?
          with :work_order_type_id, type
        end
        if !labor.blank?
          with :work_order_labor_id, labor
        end
        if !status.blank?
          with :work_order_status_id, status
        end
        order_by :sort_no, :desc
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
      @subscriber_meter = subscriber_meter_required(@work_order)
      @suborders = @work_order.suborders.paginate(:page => params[:page], :per_page => per_page).by_no

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
      @woareas = work_order_areas_dropdown
      @types = work_order_types_dropdown
      @labors = work_order_labors_dropdown
      @infrastructures = infrastructures_dropdown
      @areas = areas_dropdown
      @charge_accounts = projects_charge_accounts(@projects)
      @stores = stores_dropdown
      @clients = clients_dropdown
      @subscribers = subscribers_dropdown
      @meters = meters_dropdown
      @meter_models = meter_models_dropdown
      @calibers = calibers_dropdown
      @meter_owners = meter_owners_dropdown
      @meter_locations = meter_locations_dropdown
      @readings = readings_dropdown(nil, nil, nil)
      @subscriber_meter = 'false'
      @master_order = master_orders_dropdown(nil, nil, nil, true)
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
      @woareas = work_order_areas_dropdown_edit(@work_order.work_order_area)
      @types = work_order_types_dropdown_edit(@work_order.work_order_type)
      @labors = work_order_labors_dropdown_edit(@work_order.work_order_labor)
      @infrastructures = infrastructures_dropdown
      @areas = areas_dropdown
      @charge_accounts = @work_order.project.blank? ? projects_charge_accounts(@projects) : charge_accounts_dropdown_edit(@work_order.project)
      @stores = project_stores(@work_order.project)
      @clients = clients_dropdown
      @subscribers = subscribers_dropdown
      @meters = meters_dropdown
      @meter_models = meter_models_dropdown
      @calibers = calibers_dropdown
      @meter_owners = meter_owners_dropdown
      @meter_locations = meter_locations_dropdown
      @readings = readings_dropdown(@work_order.project, @work_order.meter, @work_order.subscriber)
      @subscriber_meter = subscriber_meter_required(@work_order)
      @master_order = master_orders_dropdown(@work_order.project, nil, @work_order.id, false)
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
          @woareas = work_order_areas_dropdown
          @types = work_order_types_dropdown
          @labors = work_order_labors_dropdown
          @infrastructures = infrastructures_dropdown
          @areas = areas_dropdown
          @charge_accounts = projects_charge_accounts(@projects)
          @stores = stores_dropdown
          @clients = clients_dropdown
          @subscribers = subscribers_dropdown
          @meters = meters_dropdown
          @meter_models = meter_models_dropdown
          @calibers = calibers_dropdown
          @meter_owners = meter_owners_dropdown
          @meter_locations = meter_locations_dropdown
          @readings = readings_dropdown(nil, nil, nil)
          @workers = workers_dropdown
          @products = products_dropdown
          @suppliers = suppliers_dropdown
          @orders = orders_dropdown
          @tools = tools_dropdown
          @vehicles = vehicles_dropdown
          @subscriber_meter = false
          @master_order = master_orders_dropdown(nil, nil, nil, true)
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

      items_changed = false
      # Vehicles
      if params[:work_order][:work_order_vehicles_attributes]
        params[:work_order][:work_order_vehicles_attributes].values.each do |new_item|
          current_item = WorkOrderVehicle.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.vehicle_id.to_i != new_item[:vehicle_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.distance.to_f != new_item[:distance].to_f) ||
              (current_item.cost.to_f != new_item[:cost].to_f)))
            items_changed = true
            break
          end
        end
      end
      # Tools
      if !items_changed && params[:work_order][:work_order_tools_attributes]
        params[:work_order][:work_order_tools_attributes].values.each do |new_item|
          current_item = WorkOrderTool.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.tool_id.to_i != new_item[:tool_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.minutes.to_f != new_item[:minutes].to_f) ||
              (current_item.cost.to_f != new_item[:cost].to_f)))
            items_changed = true
            break
          end
        end
      end
      # Subcontractors
      if !items_changed && params[:work_order][:work_order_subcontractors_attributes]
        params[:work_order][:work_order_subcontractors_attributes].values.each do |new_item|
          current_item = WorkOrderSubcontractor.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.supplier_id.to_i != new_item[:supplier_id].to_i) ||
              (current_item.purchase_order_id.to_i != new_item[:purchase_order_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.enforcement_pct.to_f != new_item[:enforcement_pct].to_f)))
            items_changed = true
            break
          end
        end
      end
      # Workers
      if !items_changed && params[:work_order][:work_order_workers_attributes]
        params[:work_order][:work_order_workers_attributes].values.each do |new_item|
          current_item = WorkOrderWorker.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.worker_id.to_i != new_item[:worker_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.hours.to_f != new_item[:hours].to_f) ||
              (current_item.cost.to_f != new_item[:cost].to_f)))
            items_changed = true
            break
          end
        end
      end
      # Items
      if !items_changed && params[:work_order][:work_order_items_attributes]
        params[:work_order][:work_order_items_attributes].values.each do |new_item|
          current_item = WorkOrderItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.description != new_item[:description]) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f) ||
              (current_item.cost.to_f != new_item[:cost].to_f) ||
              (current_item.price.to_f != new_item[:price].to_f) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.tax_type_id.to_i != new_item[:tax_type_id].to_i)))
            items_changed = true
            break
          end
        end
      end
      # Master
      master_changed = false
      if ((params[:work_order][:organization_id].to_i != @work_order.organization_id.to_i) ||
          (params[:work_order][:project_id].to_i != @work_order.project_id.to_i) ||
          (params[:work_order][:client_id].to_i != @work_order.client_id.to_i) ||
          (params[:work_order][:work_order_area_id].to_i != @work_order.work_order_area_id.to_i) ||
          (params[:work_order][:work_order_type_id].to_i != @work_order.work_order_type_id.to_i) ||
          (params[:work_order][:description] != @work_order.description) ||
          (params[:work_order][:work_order_labor_id].to_i != @work_order.work_order_labor_id.to_i) ||
          (params[:work_order][:infrastructure_id].to_i != @work_order.infrastructure_id.to_i) ||
          (params[:work_order][:work_order_status_id].to_i != @work_order.work_order_status_id.to_i) ||
          (params[:work_order][:area_id].to_i != @work_order.area_id.to_i) ||
          (params[:work_order][:in_charge_id].to_i != @work_order.in_charge_id.to_i) ||
          (params[:work_order][:charge_account_id].to_i != @work_order.charge_account_id.to_i) ||
          (params[:work_order][:store_id].to_i != @work_order.store_id.to_i) ||
          (params[:work_order][:client_id].to_i != @work_order.client_id.to_i) ||
          (params[:work_order][:petitioner] != @work_order.petitioner) ||
          (params[:work_order][:location] != @work_order.location) ||
          (params[:work_order][:pub_record] != @work_order.pub_record) ||
          (params[:work_order][:started_at].to_datetime != @work_order.started_at) ||
          (params[:work_order][:completed_at].to_datetime != @work_order.completed_at) ||
          (params[:work_order][:closed_at].to_datetime != @work_order.closed_at) ||
          (params[:work_order][:reported_at].to_datetime != @work_order.reported_at) ||
          (params[:work_order][:approved_at].to_datetime != @work_order.approved_at) ||
          (params[:work_order][:certified_at].to_datetime != @work_order.certified_at) ||
          (params[:work_order][:posted_at].to_datetime != @work_order.posted_at) ||
          (params[:work_order][:hours_type].to_i != @work_order.hours_type) ||
          (params[:work_order][:master_order_id].to_i != @work_order.master_order_id.to_i) ||
          (params[:work_order][:remarks].to_s != @work_order.remarks))
        master_changed = true
      end
      #@work_order.work_order_items.assign_attributes(params[:work_order][:work_order_items_attributes])

      respond_to do |format|
        if master_changed || items_changed
          @work_order.updated_by = current_user.id if !current_user.nil?
          if @work_order.update_attributes(params[:work_order])
            format.html { redirect_to @work_order,
                          notice: (crud_notice('updated', @work_order) + "#{undo_link(@work_order)}").html_safe }
            format.json { head :no_content }
          else
            @projects = projects_dropdown_edit(@work_order.project)
            @woareas = work_order_areas_dropdown_edit(@work_order.work_order_area)
            @types = work_order_types_dropdown_edit(@work_order.work_order_type)
            @labors = work_order_labors_dropdown_edit(@work_order.work_order_labor)
            @infrastructures = infrastructures_dropdown
            @areas = areas_dropdown
            @charge_accounts = @work_order.project.blank? ? projects_charge_accounts(@projects) : charge_accounts_dropdown_edit(@work_order.project)
            @stores = project_stores(@work_order.project)
            @clients = clients_dropdown
            @subscribers = subscribers_dropdown
            @meters = meters_dropdown
            @meter_models = meter_models_dropdown
            @calibers = calibers_dropdown
            @meter_owners = meter_owners_dropdown
            @meter_locations = meter_locations_dropdown
            @readings = readings_dropdown(@work_order.project, @work_order.meter, @work_order.subscriber)
            @workers = project_workers(@work_order.project)
            @products = @work_order.organization.blank? ? products_dropdown : @work_order.organization.products(:product_code)
            @suppliers = @work_order.organization.blank? ? suppliers_dropdown : @work_order.organization.suppliers(:supplier_code)
            @orders = orders_dropdown_edit(@work_order, nil)
            @tools = tools_dropdown_edit(@work_order)
            @vehicles = vehicles_dropdown_edit(@work_order)
            @subscriber_meter = subscriber_meter_required(@work_order)
            @master_order = master_orders_dropdown(@work_order.project, nil, @work_order.id, false)
            format.html { render action: "edit" }
            format.json { render json: @work_order.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @work_order }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /work_orders/1
    # DELETE /work_orders/1.json
    def destroy
      @work_order = WorkOrder.find(params[:id])

      respond_to do |format|
        if @work_order.destroy
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
      @items = @work_order.work_order_items.order(:id)
      @workers = @work_order.work_order_workers.order(:id)
      @subcontractors = @work_order.work_order_subcontractors.order(:id)
      @tools = @work_order.work_order_tools.order(:id)
      @vehicles = @work_order.work_order_vehicles.order(:id)

      title = t("activerecord.models.work_order.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@work_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Report with subscriber & meter
    def work_order_form_sm
      # Search work order & items
      @work_order = WorkOrder.find(params[:id])
      @items = @work_order.work_order_items.order(:id)
      @workers = @work_order.work_order_workers.order(:id)
      @subcontractors = @work_order.work_order_subcontractors.order(:id)
      @tools = @work_order.work_order_tools.order(:id)
      @vehicles = @work_order.work_order_vehicles.order(:id)

      title = t("activerecord.models.work_order.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@work_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Report empty
    def work_order_form_empty
      # Search work order & items
      @work_order = WorkOrder.find(params[:id])

      title = t("activerecord.models.work_order.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@work_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Report empty with subscriber & meter
    def work_order_form_empty_sm
      # Search work order & items
      @work_order = WorkOrder.find(params[:id])

      title = t("activerecord.models.work_order.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@work_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # work order report
    def work_order_report
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      area = params[:Area]
      type = params[:Type]
      labor = params[:Labor]
      status = params[:Status]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = WorkOrder.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :order_no, no
          else
            with(:order_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !area.blank?
          with :work_order_area_id, area
        end
        if !type.blank?
          with :work_order_type_id, type
        end
        if !labor.blank?
          with :work_order_labor_id, labor
        end
        if !status.blank?
          with :work_order_status_id, status
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => WorkOrder.count
      end

      @work_order_report = @search.results

      if !@work_order_report.blank?
        title = t("activerecord.models.work_order.few")
        @to = formatted_date(@work_order_report.first.created_at)
        @from = formatted_date(@work_order_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
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

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      WorkOrder.where('order_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.order_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    # Stores belonging to selected project
    def project_stores(_project)
      _array = []
      _stores = nil

      # Adding stores belonging to current project only
      # Stores with exclusive office
      if !_project.company.blank? && !_project.office.blank?
        _stores = Store.where("(company_id = ? AND office_id = ?)", _project.company.id, _project.office.id)
      elsif !_project.company.blank? && _project.office.blank?
        _stores = Store.where("(company_id = ?)", _project.company.id)
      elsif _project.company.blank? && !_project.office.blank?
        _stores = Store.where("(office_id = ?)", _project.office.id)
      else
        _stores = nil
      end
      ret_array(_array, _stores, 'id')
      # Stores with multiple offices
      if !_project.office.blank?
        _stores = StoreOffice.where("office_id = ?", _project.office.id)
        ret_array(_array, _stores, 'store_id')
      end

      # Returning founded stores
      _stores = Store.where(id: _array).order(:name)
=begin
      if _stores.blank?
        # Adding company stores, not JIT, if OCO office is not active
        if session[:office] == '0' && !_project.company.blank?
          _stores = Store.where("company_id = ? AND office_id IS NULL AND supplier_id IS NULL", _project.company_id)
        elsif session[:office] == '0' && session[:company] != '0'
          #_stores = Store.where(company_id: session[:company].to_i).order(:name)
          _stores = Store.where("company_id = ? AND office_id IS NULL AND supplier_id IS NULL", session[:company].to_i)
        end
        ret_array(_array, _stores)
        # Adding JIT stores, if OCO company is not active
        if session[:company] == '0'
          _stores = session[:organization] != '0' ? Store.where("organization_id = ? AND company_id IS NULL AND NOT supplier_id IS NULL", session[:organization].to_i) : Store.where("(company_id IS NULL AND NOT supplier_id IS NULL)")
          ret_array(_array, _stores)
        end
      end
=end
    end

    # Workers belonging to selected project
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

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _projects.each do |i|
        _ret = ChargeAccount.expenditures.where(project_id: i.id)
        ret_array(_array, _ret, 'id')
      end

      # Adding global charge accounts belonging to projects organizations
      _sort_projects_by_organization = _projects.sort { |a,b| a.organization_id <=> b.organization_id }
      _previous_organization = _sort_projects_by_organization.first.organization_id
      _sort_projects_by_organization.each do |i|
        if _previous_organization != i.organization_id
          # when organization changes, process previous
          _ret = ChargeAccount.expenditures.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
          ret_array(_array, _ret, 'id')
          _previous_organization = i.organization_id
        end
      end
      # last organization, process previous
      _ret = ChargeAccount.expenditures.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
      ret_array(_array, _ret, 'id')

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
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

    def work_order_areas_dropdown
      session[:organization] != '0' ? WorkOrderArea.where(organization_id: session[:organization].to_i).order(:name) : WorkOrderArea.order(:name)
    end

    def work_order_areas_dropdown_edit(_area)
      _areas = work_order_areas_dropdown
      if _areas.blank?
        _areas = WorkOrderArea.where(id: _area)
      end
      _areas
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

    def infrastructures_dropdown
      if session[:office] != '0'
        Infrastructure.where('office_id = ? OR (office_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:organization].to_i).order(:code)
      elsif session[:company] != '0'
        Infrastructure.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).order(:code)
      else
        session[:organization] != '0' ? Infrastructure.where(organization_id: session[:organization].to_i).order(:code) : Infrastructure.order(:code)
      end
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.expenditures.where(organization_id: session[:organization].to_i) : ChargeAccount.expenditures
    end

    def charge_accounts_dropdown_edit(_project)
      #_accounts = ChargeAccount.where('project_id = ? OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
      ChargeAccount.expenditures.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
    end

    def type_account(_type, _project)
      # Default analytical account for current work order type
      _account = nil
      if !_type.blank?
        if _project != '0'
          _account = WorkOrderTypeAccount.where('work_order_type_id = ? AND project_id = ? ', _type, _project).first.charge_account rescue nil
        end
        if _account.nil?
          _account = WorkOrderType.find(_type).charge_account rescue nil
        end
      end
      _account
    end

    def workers_dropdown
      session[:organization] != '0' ? Worker.where(organization_id: session[:organization].to_i).order(:worker_code) : Worker.order(:worker_code)
    end

    def stores_dropdown
      _array = []
      _stores = nil
      _store_offices = nil

      if session[:office] != '0'
        _stores = Store.where(office_id: session[:office].to_i)
        _store_offices = StoreOffice.where("office_id = ?", session[:office].to_i)
      elsif session[:company] != '0'
        _stores = Store.where(company_id: session[:company].to_i)
      else
        _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i) : Store.order
      end

      # Returning founded stores
      ret_array(_array, _stores, 'id')
      ret_array(_array, _store_offices, 'store_id')
      _stores = Store.where(id: _array).order(:name)
    end

    def areas_dropdown
      session[:organization] != '0' ? Area.joins(:department).where(departments: { organization_id: session[:organization].to_i }).order(:name) : Area.order(:name)
    end

    def clients_dropdown
      # Clients are shared by all organizations
      session[:organization] != '0' ? Client.where(organization_id: session[:organization].to_i).order(:client_code) : Client.order(:client_code)
    end

    def subscribers_dropdown
      # Subscribers by current office, company or organization
      if session[:office] != '0'
        Subscriber.find_by_office(session[:office].to_i, session[:organization].to_i)
      elsif session[:company] != '0'
        Subscriber.find_by_company(session[:company].to_i, session[:organization].to_i)
      else
        session[:organization] != '0' ? Subscriber.find_by_organization(session[:organization].to_i) : Subscriber.by_code
      end
    end

    def meters_dropdown
      # Meters by current office, company or organization
      if session[:office] != '0'
        Meter.where('office_id = ? OR (office_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:organization].to_i).order(:meter_code)
      elsif session[:company] != '0'
        Meter.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).order(:meter_code)
      else
        session[:organization] != '0' ? Meter.where(organization_id: session[:organization].to_i).order(:meter_code) : Meter.order(:meter_code)
      end
    end

    # Master work orders by project or organization
    # WARNING: Cannot includes dependent suborders when editing!
    def master_orders_dropdown(_project = nil, _organization = nil, _this = nil, _is_new = false)
      if _is_new
        # New: Return work orders including suborders
        if !_project.blank?
          # Project's orders
          if !_this.blank?
            # Not including current order
            WorkOrder.belongs_to_project_unclosed_without_this(_project, _this)
          else
            # All project's orders
            WorkOrder.belongs_to_project_unclosed(_project)
          end
        elsif !_organization.blank?
          # Project not passed: Organization's orders
          if !_this.blank?
            # Not including current order
            WorkOrder.belongs_to_organization_unclosed_without_this(_organization, _this)
          else
            # All organization's orders
            WorkOrder.belongs_to_organization_unclosed(_organization)
          end
        else
          # Project & organization not passed: All orders
          if !_this.blank?
            # All orders, not including current order (unless organization is active in session)
            session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed_without_this(session[:organization].to_i, _this) : WorkOrder.unclosed_only_without_this(_this)
          else
            # All orders (unless organization is active in session)
            session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed(session[:organization].to_i) : WorkOrder.unclosed_only
          end
        end
      else
        # Existing: If master, cannot includes suborders
        if !_project.blank?
          # Project's orders
          if !_this.blank?
            # Not including current order
            WorkOrder.belongs_to_project_unclosed_without_this_and_suborders(_project, _this)
          else
            # All project's orders
            WorkOrder.belongs_to_project_unclosed_without_suborders(_project)
          end
        elsif !_organization.blank?
          # Project not passed: Organization's orders
          if !_this.blank?
            # Not including current order
            WorkOrder.belongs_to_organization_unclosed_without_this_and_suborders(_organization, _this)
          else
            # All organization's orders
            WorkOrder.belongs_to_organization_unclosed_without_suborders(_organization)
          end
        else
          # Project & organization not passed: All orders
          if !_this.blank?
            # All orders, not including current order (unless organization is active in session)
            session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed_without_this_and_suborders(session[:organization].to_i, _this) : WorkOrder.unclosed_only_without_this_and_suborders(_this)
          else
            # All orders (unless organization is active in session)
            session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed_without_suborders(session[:organization].to_i) : WorkOrder.unclosed_only_without_suborders
          end
        end
      end
    end

    # WARNING: Do not use! (includes dependent suborders)
    def master_orders_dropdown_dont_use(_project = nil, _organization = nil, _this = nil)
      if !_project.blank?
        # Project's orders
        if !_this.blank?
          # Not including current order
          WorkOrder.belongs_to_project_unclosed_without_this(_project, _this)
        else
          # All project's orders
          WorkOrder.belongs_to_project_unclosed(_project)
        end
      elsif !_organization.blank?
        # Project not passed: Organization's orders
        if !_this.blank?
          # Not including current order
          WorkOrder.belongs_to_organization_unclosed_without_this(_organization, _this)
        else
          # All organization's orders
          WorkOrder.belongs_to_organization_unclosed(_organization)
        end
      else
        # Project & organization not passed: All orders
        if !_this.blank?
          # All orders, not including current order (unless organization is active in session)
          session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed_without_this(session[:organization].to_i, _this) : WorkOrder.unclosed_only_without_this(_this)
        else
          # All orders (unless organization is active in session)
          session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed(session[:organization].to_i) : WorkOrder.unclosed_only
        end
      end
    end

    def meter_models_dropdown
      MeterModel.by_brand_model
    end

    def calibers_dropdown
      Caliber.by_caliber
    end

    def meter_owners_dropdown
      MeterOwner.all
    end

    def meter_locations_dropdown
      MeterLocation.all
    end

    def readings_dropdown(_project, _meter, _subscriber)
      # Readings by current project, meter and subscriber
      if _project.blank? || _meter.blank? || _subscriber.blank?
        Reading.where(project_id: nil)
      else
        Reading.where('project_id = ? AND meter_id = ? AND subscriber_id = ?', _project, _meter, _subscriber).by_date_desc
      end
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

    def infrastructures_dropdown
      if session[:office] != '0'
        Infrastructure.where('office_id = ? OR (office_id IS NULL AND company_id = ?) OR (office_id IS NULL AND company_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:company].to_i, session[:organization].to_i).order(:code)
      elsif session[:company] != '0'
        Infrastructure.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).order(:code)
      else
        session[:organization] != '0' ? Infrastructure.where(organization_id: session[:organization].to_i).order(:code) : Infrastructure.order(:code)
      end
    end

    def subscriber_meter_required(_work_order)
      _required = 'false'
      _labor = _work_order.work_order_labor rescue nil
      _type = _work_order.work_order_type rescue nil
      # By labor
      if !_labor.nil?
        _required = _labor.subscriber_meter.to_s
      end
      # By type
      if _required != 'true' && !_type.nil?
        _required = _type.subscriber_meter.to_s
      end
      _required.blank? ? 'false' : _required
    end

    def orders_array(_orders)
      _orders_array = []
      _orders.each do |i|
        _orders_array = _orders_array << [i.id, i.full_no, formatted_date(i.order_date), i.supplier.full_name]
      end
      _orders_array
    end

    def areas_array(_areas)
      _array = []
      _areas.each do |i|
        _array = _array << [i.id, i.name, i.department.name]
      end
      _array
    end

    def products_array(_products)
      _array = []
      _products.each do |i|
        _array = _array << [i.id, i.full_code, i.main_description[0,40]]
      end
      _array
    end

    def tools_array(_tools)
      _array = []
      _tools.each do |i|
        _array = _array << [i.id, i.serial_no, i.name[0,40]]
      end
      _array
    end

    def vehicles_array(_vehicles)
      _array = []
      _vehicles.each do |i|
        _array = _array << [i.id, i.registration, i.name[0,40]]
      end
      _array
    end

    def orders_array(_orders)
      _array = []
      _orders.each do |i|
        _array = _array << [i.id, i.full_name]
      end
      _array
    end

    # Returns _array from _ret table/model filled with _id attribute
    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
      end
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
      # area
      if params[:Area]
        session[:Area] = params[:Area]
      elsif session[:Area]
        params[:Area] = session[:Area]
      end
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end
      # labor
      if params[:Labor]
        session[:Labor] = params[:Labor]
      elsif session[:Labor]
        params[:Labor] = session[:Labor]
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
