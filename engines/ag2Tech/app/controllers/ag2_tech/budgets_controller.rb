require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

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
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/1/edit
    def edit
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
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
