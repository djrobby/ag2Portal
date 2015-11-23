require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeAccountsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:cc_update_project_textfields_from_organization,
                                               :cc_generate_code]
    
    # Update project text fields at view from organization select
    def cc_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @groups = @organization.blank? ? groups_dropdown : @organization.charge_groups.order(:group_code)
      else
        @projects = projects_dropdown
        @groups = groups_dropdown
      end
      @json_data = { "projects" => @projects, "groups" => @groups }
      render json: @json_data
    end

    # Update account code at view (generate_code_btn)
    def cc_generate_code
      group = params[:group]
      organization = params[:org]
      project = params[:prj]

      # Builds code, if possible
      if group == '$' || organization == '$'
        code = '$err'
      else
        code = cc_next_code(organization, group, project)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /charge_accounts
    # GET /charge_accounts.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      group = params[:Group]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @groups = groups_dropdown if @groups.nil?
  
      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = ChargeAccount.search do
        any_of do
          with :project_id, current_projects
          with :project_id, nil
        end
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :account_code, no
          else
            with(:account_code).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !group.blank?
          with :charge_group_id, group
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @charge_accounts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @charge_accounts }
        format.js
      end
    end
  
    # GET /charge_accounts/1
    # GET /charge_accounts/1.json
    def show
      @breadcrumb = 'read'
      @charge_account = ChargeAccount.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/new
    # GET /charge_accounts/new.json
    def new
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new
      @projects = projects_dropdown
      @groups = groups_dropdown
      @ledger_accounts = ledger_accounts_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/1/edit
    def edit
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
      @projects = projects_dropdown_edit(@charge_account.project)
      @groups = @charge_account.organization.blank? ? groups_dropdown : @charge_account.organization.charge_groups.order(:group_code)
      @ledger_accounts = @charge_account.organization.blank? ? ledger_accounts_dropdown : @charge_account.organization.ledger_accounts.order(:code)
    end
  
    # POST /charge_accounts
    # POST /charge_accounts.json
    def create
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new(params[:charge_account])
      @charge_account.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.save
          format.html { redirect_to @charge_account, notice: crud_notice('created', @charge_account) }
          format.json { render json: @charge_account, status: :created, location: @charge_account }
        else
          @projects = projects_dropdown
          @groups = groups_dropdown
          @ledger_accounts = ledger_accounts_dropdown
          format.html { render action: "new" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /charge_accounts/1
    # PUT /charge_accounts/1.json
    def update
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
      @charge_account.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.update_attributes(params[:charge_account])
          format.html { redirect_to @charge_account,
                        notice: (crud_notice('updated', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          @projects = projects_dropdown_edit(@charge_account.project)
          @groups = @charge_account.organization.blank? ? groups_dropdown : @charge_account.organization.charge_groups.order(:group_code)
          @ledger_accounts = @charge_account.organization.blank? ? ledger_accounts_dropdown : @charge_account.organization.ledger_accounts.order(:code)
          format.html { render action: "edit" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /charge_accounts/1
    # DELETE /charge_accounts/1.json
    def destroy
      @charge_account = ChargeAccount.find(params[:id])

      respond_to do |format|
        if @charge_account.destroy
          format.html { redirect_to charge_accounts_url,
                      notice: (crud_notice('destroyed', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to charge_accounts_url, alert: "#{@charge_account.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
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
      ChargeAccount.where('account_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.account_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.active_only.where(office_id: session[:office].to_i)
      elsif session[:company] != '0'
        _projects = Project.active_only.where(company_id: session[:company].to_i)
      else
        _projects = session[:organization] != '0' ? Project.active_only.where(organization_id: session[:organization].to_i) : Project.active_only
      end
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def groups_dropdown
      session[:organization] != '0' ? ChargeGroup.where(organization_id: session[:organization].to_i).order(:group_code) : ChargeGroup.order(:group_code)
    end

    def ledger_accounts_dropdown
      session[:organization] != '0' ? LedgerAccount.where(organization_id: session[:organization].to_i).order(:code) : LedgerAccount.order(:code)
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
      # group
      if params[:Group]
        session[:Group] = params[:Group]
      elsif session[:Group]
        params[:Group] = session[:Group]
      end
    end
  end
end
