require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrdersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:wo_update_account_textfield_from_project,
                                               :wo_update_worker_select_from_area,
                                               :wo_update_petitioner_textfield_from_client,
                                               :wo_item_totals,
                                               :wo_worker_totals,
                                               :wo_update_description_prices_from_product,
                                               :wo_update_costs_from_worker]
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
      average = hours / count
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
      description = ""
      qty = 0
      cost = 0
      costs = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
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
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description,
                     "cost" => cost.to_s, "costs" => costs.to_s,
                     "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id }

      respond_to do |format|
        format.html # wo_update_description_prices_from_product.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update cost text fields at view from worker select
    def wo_update_costs_from_worker
      worker = params[:worker]
      hours = 0
      cost = 0
      costs = 0
      if worker != '0'
        @worker = Worker.find(worker)
        # Look for working day percentage and calculate cost per hour
        # Assignment
        hours = params[:hours].to_f / 10000
        costs = hours * cost
      end
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
    
    # Update account text field at view from project select
    def wo_update_account_textfield_from_project
      project = params[:id]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? ChargeAccount.all(order: 'account_code') : @project.charge_accounts(order: 'account_code')
        @store = project_stores(@project)
        @worker = project_workers(@project)
      else
        @charge_account = ChargeAccount.all(order: 'account_code')
        @store = Store.all(order: 'name')
        @worker = Worker.order(:last_name, :first_name)
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

    #
    # Default Methods
    #
    # GET /work_orders
    # GET /work_orders.json
    def index
      project = params[:Project]
      type = params[:Type]
      status = params[:Status]

      @search = WorkOrder.search do
        fulltext params[:search]
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

      # Initialize select_tags
      @projects = Project.order('name') if @projects.nil?
      @types = WorkOrderType.order('name') if @types.nil?
      @statuses = WorkOrderStatus.order('id') if @statuses.nil?
  
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
      @charge_accounts = ChargeAccount.order(:account_code)
      @workers = Worker.order(:last_name, :first_name)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order }
      end
    end
  
    # GET /work_orders/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order = WorkOrder.find(params[:id])
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
          @charge_accounts = ChargeAccount.order(:account_code)
          @workers = Worker.order(:last_name, :first_name)
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
  end
end
