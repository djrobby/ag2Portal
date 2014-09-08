require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetPeriodsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /budget_periods
    # GET /budget_periods.json
    def index
      manage_filter_state
      filter = params[:ifilter]
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @budget_periods = expiration_filter_organization(filter, session[:organization].to_i)
      else
        @budget_periods = expiration_filter(filter)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @budget_periods }
        format.js
      end
    end
  
    # GET /budget_periods/1
    # GET /budget_periods/1.json
    def show
      @breadcrumb = 'read'
      @budget_period = BudgetPeriod.find(params[:id])
      @budgets = @budget_period.budgets.paginate(:page => params[:page], :per_page => per_page).order(:budget_no)
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @budget_period }
      end
    end
  
    # GET /budget_periods/new
    # GET /budget_periods/new.json
    def new
      @breadcrumb = 'create'
      @budget_period = BudgetPeriod.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget_period }
      end
    end
  
    # GET /budget_periods/1/edit
    def edit
      @breadcrumb = 'update'
      @budget_period = BudgetPeriod.find(params[:id])
    end
  
    # POST /budget_periods
    # POST /budget_periods.json
    def create
      @breadcrumb = 'create'
      @budget_period = BudgetPeriod.new(params[:budget_period])
      @budget_period.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget_period.save
          format.html { redirect_to @budget_period, notice: crud_notice('created', @budget_period) }
          format.json { render json: @budget_period, status: :created, location: @budget_period }
        else
          format.html { render action: "new" }
          format.json { render json: @budget_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /budget_periods/1
    # PUT /budget_periods/1.json
    def update
      @breadcrumb = 'update'
      @budget_period = BudgetPeriod.find(params[:id])
      @budget_period.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget_period.update_attributes(params[:budget_period])
          format.html { redirect_to @budget_period,
                        notice: (crud_notice('updated', @budget_period) + "#{undo_link(@budget_period)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @budget_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /budget_periods/1
    # DELETE /budget_periods/1.json
    def destroy
      @budget_period = BudgetPeriod.find(params[:id])

      respond_to do |format|
        if @budget_period.destroy
          format.html { redirect_to budget_periods_url,
                      notice: (crud_notice('destroyed', @budget_period) + "#{undo_link(@budget_period)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to budget_periods_url, alert: "#{@budget_period.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @budget_period.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def expiration_filter(_filter)
      if _filter == "all"
        _groups = BudgetPeriod.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "current"
        _groups = BudgetPeriod.where("ending_at IS NULL").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "expired"
        _groups = BudgetPeriod.where("NOT ending_at IS NULL").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _groups = BudgetPeriod.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _groups
    end

    def expiration_filter_organization(_filter, _organization)
      if _filter == "all"
        _groups = BudgetPeriod.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "current"
        _groups = BudgetPeriod.where("(ending_at IS NULL) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "expired"
        _groups = BudgetPeriod.where("(NOT ending_at IS NULL) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _groups = BudgetPeriod.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _groups
    end

    def sort_column
      BudgetPeriod.column_names.include?(params[:sort]) ? params[:sort] : "period_code"
    end

    # Keeps filter state
    def manage_filter_state
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
      # ifilter
      if params[:ifilter]
        session[:ifilter] = params[:ifilter]
      elsif session[:ifilter]
        params[:ifilter] = session[:ifilter]
      end
    end
  end
end
