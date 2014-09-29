require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:bu_item_totals,
                                               :bu_update_corrected,
                                               :bu_update_annual,
                                               :bu_update_account_textfields_from_project,
                                               :bu_update_project_textfield_from_organization,
                                               :bu_generate_no,
                                               :bu_new]
    # Calculate and format item totals properly
    def bu_item_totals
      total01 = params[:m01].to_f / 10000
      total02 = params[:m02].to_f / 10000
      total03 = params[:m03].to_f / 10000
      total04 = params[:m04].to_f / 10000
      total05 = params[:m05].to_f / 10000
      total06 = params[:m06].to_f / 10000
      total07 = params[:m07].to_f / 10000
      total08 = params[:m08].to_f / 10000
      total09 = params[:m09].to_f / 10000
      total10 = params[:m10].to_f / 10000
      total11 = params[:m11].to_f / 10000
      total12 = params[:m12].to_f / 10000
      annual = params[:anu].to_f / 10000
      corrected = params[:cor].to_f / 10000
      # Total income
      # Total expenditure
      # Format output values
      total01 = number_with_precision(total01.round(4), precision: 4)
      total02 = number_with_precision(total02.round(4), precision: 4)
      total03 = number_with_precision(total03.round(4), precision: 4)
      total04 = number_with_precision(total04.round(4), precision: 4)
      total05 = number_with_precision(total05.round(4), precision: 4)
      total06 = number_with_precision(total06.round(4), precision: 4)
      total07 = number_with_precision(total07.round(4), precision: 4)
      total08 = number_with_precision(total08.round(4), precision: 4)
      total09 = number_with_precision(total09.round(4), precision: 4)
      total10 = number_with_precision(total10.round(4), precision: 4)
      total11 = number_with_precision(total11.round(4), precision: 4)
      total12 = number_with_precision(total12.round(4), precision: 4)
      annual = number_with_precision(annual.round(4), precision: 4)
      corrected = number_with_precision(corrected.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "total01" => total01.to_s, "total02" => total02.to_s, "total03" => total03.to_s, "total04" => total04.to_s,
                     "total05" => total05.to_s, "total06" => total06.to_s, "total07" => total07.to_s, "total08" => total08.to_s,
                     "total09" => total09.to_s, "total10" => total10.to_s, "total11" => total11.to_s, "total12" => total12.to_s,
                     "annual" => annual.to_s, "corrected" => corrected.to_s }
      render json: @json_data
    end

    # Update corrected text field at view
    def bu_update_corrected
      corrected = params[:cor].to_f / 10000
      corrected = number_with_precision(corrected.round(4), precision: 4)
      @json_data = { "corrected" => corrected.to_s }
      render json: @json_data
    end

    # Update annual text field at view (some monthXX changed)
    def bu_update_annual
      total01 = params[:m01].to_f / 10000
      total02 = params[:m02].to_f / 10000
      total03 = params[:m03].to_f / 10000
      total04 = params[:m04].to_f / 10000
      total05 = params[:m05].to_f / 10000
      total06 = params[:m06].to_f / 10000
      total07 = params[:m07].to_f / 10000
      total08 = params[:m08].to_f / 10000
      total09 = params[:m09].to_f / 10000
      total10 = params[:m10].to_f / 10000
      total11 = params[:m11].to_f / 10000
      total12 = params[:m12].to_f / 10000
      annual = total01 + total02 + total03 + total04 + total05 + total06 +
               total07 + total08 + total09 + total10 + total11 + total12
      @json_data = { "total01" => total01.to_s, "total02" => total02.to_s, "total03" => total03.to_s, "total04" => total04.to_s,
                     "total05" => total05.to_s, "total06" => total06.to_s, "total07" => total07.to_s, "total08" => total08.to_s,
                     "total09" => total09.to_s, "total10" => total10.to_s, "total11" => total11.to_s, "total12" => total12.to_s,
                     "annual" => annual.to_s }
      render json: @json_data
    end
    
    # Update item-table account text fields at view from project select
    def bu_update_account_textfields_from_project
      project = params[:project]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
        @old_budgets = @project.blank? ? budgets_dropdown : budgets_dropdown_edit(@project.id)
      else
        @charge_account = charge_accounts_dropdown
        @old_budgets = budgets_dropdown
      end
      @json_data = { "charge_account" => @charge_account }
      render json: @json_data
    end

    # Update project text field at view from organization select
    def bu_update_project_textfield_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @old_budgets = @organization.blank? ? budgets_dropdown : @organization.budgets.order('budget_no DESC')
      else
        @projects = projects_dropdown
        @old_budgets = budgets_dropdown
      end
      @json_data = { "project" => @projects }
      render json: @json_data
    end

    # Update budget number at view (generate_code_btn)
    def bu_generate_no
      project = params[:project]
      period = params[:period]

      # Builds no, if possible
      if project == '$' || period == '$'
        code = '$err'
      else
        code = bu_next_no(project, period)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Inherits new Budget from the chosen one
    def bu_inherit
      
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
      @projects = projects_dropdown
      @periods = periods_dropdown
      @charge_accounts = charge_accounts_dropdown
      @old_budgets = budgets_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/1/edit
    def edit
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
      @projects = projects_dropdown
      @periods = periods_dropdown
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
          @projects = projects_dropdown
          @periods = periods_dropdown
          @charge_accounts = charge_accounts_dropdown
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
          @projects = projects_dropdown
          @periods = periods_dropdown
          @charge_accounts = @budget.project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@budget.project_id)
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

    def budgets_dropdown
      session[:organization] != '0' ? Budget.where(organization_id: session[:organization].to_i).order('budget_no DESC') : Budget.order('budget_no DESC')
    end

    def budgets_dropdown_edit(_project)
      _budgets = Budget.where(project_id: _project).order('budget_no DESC')
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
