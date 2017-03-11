require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class LedgerAccountsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:la_update_project_textfield_from_organization,
                                               :la_update_accounting_group_from_code]
    # Helper methods for sorting
    helper_method :sort_column

    # Update project text at view from organization select
    def la_update_project_textfield_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
      else
        @projects = projects_dropdown
      end
      @json_data = { "project" => @projects }
      render json: @json_data
    end

    # Update accounting group select at view from code text
    def la_update_accounting_group_from_code
      code = params[:code]
      _id = 0
      if code != '0' && code.length > 0
        _accounting_groups = AccountingGroup.where(code: code[0])
        _id = _accounting_groups.blank? ? 0 : _accounting_groups.first.id
      end
      @json_data = { "accounting_group_id" => _id }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /ledger_accounts
    # GET /ledger_accounts.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @ledger_accounts = LedgerAccount.where(organization_id: session[:organization]).includes(:accounting_group).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @ledger_accounts = LedgerAccount.includes(:accounting_group).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ledger_accounts }
        format.js
      end
    end

    # GET /ledger_accounts/1
    # GET /ledger_accounts/1.json
    def show
      @breadcrumb = 'read'
      @ledger_account = LedgerAccount.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ledger_account }
      end
    end

    # GET /ledger_accounts/new
    # GET /ledger_accounts/new.json
    def new
      @breadcrumb = 'create'
      @ledger_account = LedgerAccount.new
      @projects = projects_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ledger_account }
      end
    end

    # GET /ledger_accounts/1/edit
    def edit
      @breadcrumb = 'update'
      @ledger_account = LedgerAccount.find(params[:id])
      @projects = projects_dropdown_edit(@ledger_account.project)
    end

    # POST /ledger_accounts
    # POST /ledger_accounts.json
    def create
      @breadcrumb = 'create'
      @ledger_account = LedgerAccount.new(params[:ledger_account])
      @ledger_account.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ledger_account.save
          format.html { redirect_to @ledger_account, notice: crud_notice('created', @ledger_account) }
          format.json { render json: @ledger_account, status: :created, location: @ledger_account }
        else
          @projects = projects_dropdown
          format.html { render action: "new" }
          format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /ledger_accounts/1
    # PUT /ledger_accounts/1.json
    def update
      @breadcrumb = 'update'
      @ledger_account = LedgerAccount.find(params[:id])
      @ledger_account.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ledger_account.update_attributes(params[:ledger_account])
          format.html { redirect_to @ledger_account,
                        notice: (crud_notice('updated', @ledger_account) + "#{undo_link(@ledger_account)}").html_safe }
          format.json { head :no_content }
        else
          @projects = projects_dropdown_edit(@ledger_account.project)
          format.html { render action: "edit" }
          format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /ledger_accounts/1
    # DELETE /ledger_accounts/1.json
    def destroy
      @ledger_account = LedgerAccount.find(params[:id])

      respond_to do |format|
        if @ledger_account.destroy
          format.html { redirect_to ledger_accounts_url,
                      notice: (crud_notice('destroyed', @ledger_account) + "#{undo_link(@ledger_account)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to ledger_accounts_url, alert: "#{@ledger_account.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      LedgerAccount.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
    end
  end
end
