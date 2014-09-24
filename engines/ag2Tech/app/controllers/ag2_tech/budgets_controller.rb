require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:bu_update_account_textfield_from_project,
                                               :bu_item_totals,
                                               :bu_worker_totals,
                                               :wo_update_amount_and_costs_from_price_or_quantity,
                                               :bu_update_project_textfield_from_organization,
                                               :bu_generate_code]
    # Calculate and format item totals properly
    def bu_item_totals
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
    
    # Update account text field at view from project select
    def bu_update_account_textfield_from_project
      project = params[:id]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
      else
        @charge_account = charge_accounts_dropdown
      end
      @json_data = { "charge_account" => @charge_account }
      render json: @json_data
    end

    # Update project text field at view from organization select
    def bu_update_project_textfields_from_organization
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
      end
      @areas_dropdown = []
      @areas.each do |i|
        @areas_dropdown = @areas_dropdown << [i.id, i.name, i.department.name] 
      end
      @json_data = { "project" => @projects, "type" => @types, "labor" => @labors,
                     "client" => @clients, "charge_account" => @charge_accounts,
                     "store" => @stores, "worker" => @workers,
                     "area" => @areas_dropdown, "product" => @products }
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
    # GET /budgets
    # GET /budgets.json
    def index
      manage_filter_state
      project = params[:Project]
      period = params[:Period]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @periods = periods_dropdown if @periods.nil?
      
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      @search = Budget.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !project.blank?
          with :project_id, project
        end
        if !period.blank?
          with :budget_period_id, period
        end
        order_by :budget_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @budgets = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @budgets }
        format.js
      end
    end
  
    # GET /budgets/1
    # GET /budgets/1.json
    def show
      @breadcrumb = 'read'
      @budget = Budget.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/new
    # GET /budgets/new.json
    def new
      @breadcrumb = 'create'
      @budget = Budget.new
      @charge_accounts = charge_accounts_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/1/edit
    def edit
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
      @charge_accounts = @budget.project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@budget.project_id)
    end
  
    # POST /budgets
    # POST /budgets.json
    def create
      @breadcrumb = 'create'
      @budget = Budget.new(params[:budget])
      @budget.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget.save
          format.html { redirect_to @budget, notice: crud_notice('created', @budget) }
          format.json { render json: @budget, status: :created, location: @budget }
        else
          format.html { render action: "new" }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /budgets/1
    # PUT /budgets/1.json
    def update
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
      @budget.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget.update_attributes(params[:budget])
          format.html { redirect_to @budget,
                        notice: (crud_notice('updated', @budget) + "#{undo_link(@budget)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /budgets/1
    # DELETE /budgets/1.json
    def destroy
      @budget = Budget.find(params[:id])

      respond_to do |format|
        if @budget.destroy
          format.html { redirect_to budgets_url,
                      notice: (crud_notice('destroyed', @budget) + "#{undo_link(@budget)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to budgets_url, alert: "#{@budget.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
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

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def periods_dropdown
      session[:organization] != '0' ? BudgetPeriod.where(organization_id: session[:organization].to_i).order(:period_code) : BudgetPeriod.order(:period_code)
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
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
      # period
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
    end
  end
end
