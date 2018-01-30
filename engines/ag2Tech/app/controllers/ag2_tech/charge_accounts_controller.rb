require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeAccountsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:cc_update_project_textfields_from_organization,
                                               :cc_update_account_textfield_from_project,
                                               :cc_update_ledger_account_select_from_company,
                                               :cc_generate_code]

    # Update project text fields at view from organization select
    def cc_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @groups = @organization.blank? ? groups_dropdown : @organization.charge_groups.order(:group_code)
        @ledger_accounts = @organization.blank? ? ledger_accounts_dropdown : @organization.ledger_accounts.order(:code)
      else
        @projects = projects_dropdown
        @groups = groups_dropdown
        @ledger_accounts = ledger_accounts_dropdown
      end
      # Ledger accounts array
      @ledger_accounts_dropdown = ledger_accounts_array(@ledger_accounts)
      # Setup JSON
      @json_data = { "projects" => @projects, "groups" => @groups, "accounts" => @ledger_accounts_dropdown }
      render json: @json_data
    end

    # Update account text field at view from project select
    def cc_update_account_textfield_from_project
      project = params[:project]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @ledger_accounts = @project.blank? ? projects_ledger_accounts(projects) : ledger_accounts_dropdown_edit(@project)
      else
        @ledger_accounts = projects_ledger_accounts(projects)
      end
      # Ledger accounts array
      @ledger_accounts_dropdown = ledger_accounts_array(@ledger_accounts)
      # Setup JSON
      @json_data = { "accounts" => @ledger_accounts_dropdown }
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

    # Update ledger account select at view from company select
    def cc_update_ledger_account_select_from_company
      company = params[:company]
      if company != '0'
        @company = Company.find(company)
        @ledger_accounts = @company.blank? ? ledger_accounts_by_company_dropdown : @company.ledger_accounts.by_code
      else
        @ledger_accounts = ledger_accounts_by_company_dropdown
      end
      # Accounts array
      @ledger_accounts_dropdown = ledger_accounts_array(@ledger_accounts)
      # Setup JSON
      @json_data = { "ledger_account" => @ledger_accounts_dropdown }
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
        data_accessor_for(ChargeAccount).include = [:charge_group, :project]
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
      @ledger_accounts = @charge_account.charge_account_ledger_accounts.paginate(:page => params[:page], :per_page => per_page).order(:id)

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
      @ledger_accounts = projects_ledger_accounts(@projects)
      @companies = companies_dropdown
      @ledger_accounts_by_company = ledger_accounts_by_company_dropdown

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
      @ledger_accounts = @charge_account.project.blank? ? projects_ledger_accounts(@projects) : ledger_accounts_dropdown_edit(@charge_account.project)
      @companies = companies_dropdown
      @ledger_accounts_by_company = ledger_accounts_by_company_dropdown
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
          @ledger_accounts = projects_ledger_accounts(@projects)
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
          @ledger_accounts = @charge_account.project.blank? ? projects_ledger_accounts(@projects) : ledger_accounts_dropdown_edit(@charge_account.project)
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

    def charge_account_report
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
        data_accessor_for(ChargeAccount).include = [:charge_group, :project]
        order_by :sort_no, :asc
        paginate :per_page => ChargeAccount.count
      end
      @charge_account_report = @search.results
      from = Date.today.to_s

      title = t("activerecord.models.charge_account.few") + "_#{from}"

      respond_to do |format|
      # Render PDF
        if !@charge_account_report.blank?
          format.pdf { send_data render_to_string,
                      filename: "#{title}.pdf",
                      type: 'application/pdf',
                      disposition: 'inline' }
          format.csv { send_data ChargeAccount.to_csv(@charge_account_report),
                      filename: "#{title}.csv",
                      type: 'application/csv',
                      disposition: 'inline' }
        else
          format.csv { redirect_to charge_accounts_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to charge_accounts_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
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

    # Ledger accounts belonging to projects
    def projects_ledger_accounts(_projects)
      _array = []
      _ret = nil

      # Adding ledger accounts belonging to current projects
      _projects.each do |i|
        _ret = LedgerAccount.where(project_id: i.id)
        ret_array(_array, _ret, 'id')
      end

      # Adding global ledger accounts belonging to projects organizations
      _sort_projects_by_organization = _projects.sort { |a,b| a.organization_id <=> b.organization_id }
      _previous_organization = _sort_projects_by_organization.first.organization_id
      _sort_projects_by_organization.each do |i|
        if _previous_organization != i.organization_id
          # when organization changes, process previous
          _ret = LedgerAccount.where('(project_id IS NULL AND ledger_accounts.organization_id = ?)', _previous_organization)
          ret_array(_array, _ret, 'id')
          _previous_organization = i.organization_id
        end
      end
      # last organization, process previous
      _ret = LedgerAccount.where('(project_id IS NULL AND ledger_accounts.organization_id = ?)', _previous_organization)
      ret_array(_array, _ret, 'id')

      # Returning founded ledger accounts
      _ret = LedgerAccount.where(id: _array).order(:code)
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

    def companies_dropdown
      if session[:company] != '0'
        Company.where(id: session[:company].to_i)
      else
        session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def ledger_accounts_dropdown
      session[:organization] != '0' ? LedgerAccount.where(organization_id: session[:organization].to_i).order(:code) : LedgerAccount.order(:code)
    end

    def ledger_accounts_by_company_dropdown
      if session[:company] != '0'
        LedgerAccount.belongs_to_company(session[:company].to_i)
      else
        session[:organization] != '0' ? LedgerAccount.belongs_to_organization(session[:organization].to_i) : LedgerAccount.by_code
      end
    end

    def ledger_accounts_dropdown_edit(_project)
      LedgerAccount.where('project_id = ? OR (project_id IS NULL AND ledger_accounts.organization_id = ?)', _project, _project.organization_id).order(:code)
    end

    def ledger_accounts_array(_accounts)
      _array = []
      _accounts.each do |i|
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
      # group
      if params[:Group]
        session[:Group] = params[:Group]
      elsif session[:Group]
        params[:Group] = session[:Group]
      end
    end
  end
end
