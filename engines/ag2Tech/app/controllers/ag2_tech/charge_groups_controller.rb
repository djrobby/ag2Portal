require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeGroupsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:cg_update_heading_textfield_from_organization]
    # Helper methods for sorting
    helper_method :sort_column
    
    # Update budget_heading text fields at view from organization select
    def cg_update_heading_textfield_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @headings = @organization.blank? ? headings_dropdown : @organization.budget_headings.order(:heading_code)
      else
        @headings = headings_dropdown
      end
      @json_data = { "headings" => @headings }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /charge_groups
    # GET /charge_groups.json
    def index
      manage_filter_state
      filter = params[:ifilter]
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @charge_groups = flow_filter_organization(filter, session[:organization].to_i)
      else
        @charge_groups = flow_filter(filter)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @charge_groups }
        format.js
      end
    end
  
    # GET /charge_groups/1
    # GET /charge_groups/1.json
    def show
      @breadcrumb = 'read'
      @charge_group = ChargeGroup.find(params[:id])
      @charge_accounts = @charge_group.charge_accounts.paginate(:page => params[:page], :per_page => per_page).order(:account_code)
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @charge_group }
      end
    end
  
    # GET /charge_groups/new
    # GET /charge_groups/new.json
    def new
      @breadcrumb = 'create'
      @charge_group = ChargeGroup.new
      @headings = headings_dropdown
      @ledger_accounts = ledger_accounts_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @charge_group }
      end
    end
  
    # GET /charge_groups/1/edit
    def edit
      @breadcrumb = 'update'
      @charge_group = ChargeGroup.find(params[:id])
      @headings = @charge_group.organization.blank? ? headings_dropdown : @charge_group.organization.budget_headings.order(:heading_code)
      @ledger_accounts = @charge_group.organization.blank? ? ledger_accounts_dropdown : @charge_group.organization.ledger_accounts.order(:code)
    end
  
    # POST /charge_groups
    # POST /charge_groups.json
    def create
      @breadcrumb = 'create'
      @charge_group = ChargeGroup.new(params[:charge_group])
      @charge_group.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_group.save
          format.html { redirect_to @charge_group, notice: crud_notice('created', @charge_group) }
          format.json { render json: @charge_group, status: :created, location: @charge_group }
        else
          @headings = headings_dropdown
          @ledger_accounts = ledger_accounts_dropdown
          format.html { render action: "new" }
          format.json { render json: @charge_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /charge_groups/1
    # PUT /charge_groups/1.json
    def update
      @breadcrumb = 'update'
      @charge_group = ChargeGroup.find(params[:id])
      @charge_group.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_group.update_attributes(params[:charge_group])
          format.html { redirect_to @charge_group,
                        notice: (crud_notice('updated', @charge_group) + "#{undo_link(@charge_group)}").html_safe }
          format.json { head :no_content }
        else
          @headings = @charge_group.organization.blank? ? headings_dropdown : @charge_group.organization.budget_headings.order(:heading_code)
          @ledger_accounts = @charge_group.organization.blank? ? ledger_accounts_dropdown : @charge_group.organization.ledger_accounts.order(:code)
          format.html { render action: "edit" }
          format.json { render json: @charge_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /charge_groups/1
    # DELETE /charge_groups/1.json
    def destroy
      @charge_group = ChargeGroup.find(params[:id])

      respond_to do |format|
        if @charge_group.destroy
          format.html { redirect_to charge_groups_url,
                      notice: (crud_notice('destroyed', @charge_group) + "#{undo_link(@charge_group)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to charge_groups_url, alert: "#{@charge_group.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @charge_group.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def flow_filter(_filter)
      if _filter == "all"
        _groups = ChargeGroup.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "income"
        _groups = ChargeGroup.where("flow = 3 OR flow = 1").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "expenditure"
        _groups = ChargeGroup.where("flow = 3 OR flow = 2").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _groups = ChargeGroup.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _groups
    end

    def flow_filter_organization(_filter, _organization)
      if _filter == "all"
        _groups = ChargeGroup.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "income"
        _groups = ChargeGroup.where("(flow = 3 OR flow = 1) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "expenditure"
        _groups = ChargeGroup.where("(flow = 3 OR flow = 2) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _groups = ChargeGroup.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _groups
    end

    def sort_column
      ChargeGroup.column_names.include?(params[:sort]) ? params[:sort] : "group_code"
    end

    def headings_dropdown
      session[:organization] != '0' ? BudgetHeading.where(organization_id: session[:organization].to_i).order(:heading_code) : BudgetHeading.order(:heading_code)
    end

    def ledger_accounts_dropdown
      session[:organization] != '0' ? LedgerAccount.where(organization_id: session[:organization].to_i).order(:group_code) : LedgerAccount.order(:group_code)
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
