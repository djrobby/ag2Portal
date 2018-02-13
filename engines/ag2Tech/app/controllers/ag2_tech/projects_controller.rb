require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ProjectsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pr_update_company_textfield_from_office,
                                               :pr_update_company_and_office_textfields_from_organization,
                                               :pr_generate_code,
                                               :pr_update_offices_select_from_company,
                                               :pr_update_total_and_price,
                                               :pr_add_plan]

    # Update company text field at view from office select
    def pr_update_company_textfield_from_office
      office = params[:id]
      @company = 0
      if office != '0'
        @office = Office.find(office)
        @company = @office.blank? ? 0 : @office.company
      end

      respond_to do |format|
        format.html # pr_update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end

    # Update company & office text fields at view from organization select
    def pr_update_company_and_office_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? companies_dropdown : @organization.companies.order(:name)
        @offices = @organization.blank? ? offices_dropdown : Office.joins(:company).where(companies: { organization_id: organization }).order(:name)
      else
        @companies = companies_dropdown
        @offices = offices_dropdown
      end
      @offices_dropdown = []
      @offices.each do |i|
        @offices_dropdown = @offices_dropdown << [i.id, i.name, i.company.name]
      end
      @json_data = { "companies" => @companies, "offices" => @offices_dropdown }
      render json: @json_data
    end

    # Update project code at view (generate_code_btn)
    def pr_generate_code
      company = params[:company]
      type = params[:type]

      # Builds code, if possible
      if company == '$' || type == '$'
        code = '$err'
      else
        code = pr_next_code(company, type)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update total & price text fields at view (formatting)
    def pr_update_total_and_price
      total = params[:total].to_f / 100
      price = params[:price].to_f / 10000
      # Format number
      total = number_with_precision(total.round(2), precision: 2)
      price = number_with_precision(price.round(4), precision: 4)
      # Setup JSON
      @json_data = { "total" => total.to_s, "price" => price.to_s }
      render json: @json_data
    end

    # Update offices from company select
    def pr_update_offices_select_from_company
      if params[:com] == '0'
        @offices = Office.order('name')
      else
        company = Company.find(params[:com])
        if !company.nil?
          @offices = company.offices.order('name')
        else
          @offices = Office.order('name')
        end
      end
      render json: @offices
    end

    # Add analytical plan to current project from chosen one
    def pr_add_plan
      code = '$ok'
      new_id = params[:id].to_i
      frm_id = params[:project]
      frm_prj = Project.find(frm_id)
      if !frm_prj.blank?
        accounts = frm_prj.charge_accounts.by_code
        accounts.each do |a|
          charge_account = ChargeAccount.new
          charge_account.name = a.name
          charge_account.opened_at = DateTime.now.to_date
          charge_account.project_id = new_id
          charge_account.created_by = current_user.id if !current_user.nil?
          charge_account.account_code = a.account_code[0..3] + params[:id].rjust(4, '0') + a.account_code[8..9]
          charge_account.organization_id = a.organization_id
          charge_account.charge_group_id = a.charge_group_id
          charge_account.ledger_account_id = a.ledger_account_id
          if !charge_account.save
            # Can't save charge account
            code = '$err'
            break
          end
        end
      end
      message = code == '$err' ? t(:process_error) : t(:process_ok)
      @json_data = { "code" => code, "message" => message }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /projects
    # GET /projects.json
    def index
      manage_filter_state
      no = params[:No]
      company = params[:WrkrCompany]
      office = params[:WrkrOffice]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      if session[:company] != '0'
        @companies = Company.where(id: session[:company]) if @companies.nil?
        company = session[:company]
      else
        @companies = Company.order(:name) if @companies.nil?
      end
      if session[:office] != '0'
        @offices = Office.where(id: session[:office]) if @offices.nil?
        office = session[:office]
      elsif session[:company] != '0'
        @offices = @companies.first.offices.order(:name) if @offices.nil?
      else
        @offices = Office.order(:name) if @offices.nil?
      end

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = Project.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :project_code, no
          else
            with(:project_code).starting_with(no)
          end
        end
        if !company.blank?
          with :company_id, company
        end
        if !office.blank?
          with :office_id, office
        end
        data_accessor_for(Project).include = [:company, :office]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @projects = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @projects }
        format.js
      end
    end

    # GET /projects/1
    # GET /projects/1.json
    def show
      @breadcrumb = 'read'
      @project = Project.find(params[:id])
      @charge_accounts = @project.charge_accounts.paginate(:page => params[:page], :per_page => per_page).by_code
      # Existing projects to generate new Analytical plan
      @current_projects = projects_dropdown

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @project }
      end
    end

    # GET /projects/new
    # GET /projects/new.json
    def new
      @breadcrumb = 'create'
      @project = Project.new
      @companies = companies_dropdown
      @offices = offices_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @project }
      end
    end

    # GET /projects/1/edit
    def edit
      @breadcrumb = 'update'
      @project = Project.find(params[:id])
      @companies = @project.organization.blank? ? companies_dropdown : companies_dropdown_edit(@project.organization)
      @offices = @project.organization.blank? ? offices_dropdown : offices_dropdown_edit(@project.organization_id)
    end

    # POST /projects
    # POST /projects.json
    def create
      @breadcrumb = 'create'
      @project = Project.new(params[:project])
      @project.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @project.save
          format.html { redirect_to @project, notice: crud_notice('created', @project) }
          format.json { render json: @project, status: :created, location: @project }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          format.html { render action: "new" }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /projects/1
    # PUT /projects/1.json
    def update
      @breadcrumb = 'update'
      @project = Project.find(params[:id])
      @project.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @project.update_attributes(params[:project])
          format.html { redirect_to @project,
                        notice: (crud_notice('updated', @project) + "#{undo_link(@project)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @project.organization.blank? ? companies_dropdown : companies_dropdown_edit(@project.organization)
          @offices = @project.organization.blank? ? offices_dropdown : offices_dropdown_edit(@project.organization_id)
          format.html { render action: "edit" }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /projects/1
    # DELETE /projects/1.json
    def destroy
      @project = Project.find(params[:id])

      respond_to do |format|
        if @project.destroy
          format.html { redirect_to projects_url,
                      notice: (crud_notice('destroyed', @project) + "#{undo_link(@project)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to projects_url, alert: "#{@project.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    def project_view_report
      manage_filter_state
      no = params[:No]
      company = params[:WrkrCompany]
      office = params[:WrkrOffice]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      if session[:company] != '0'
        @companies = Company.where(id: session[:company]) if @companies.nil?
        company = session[:company]
      else
        @companies = Company.order(:name) if @companies.nil?
      end
      if session[:office] != '0'
        @offices = Office.where(id: session[:office]) if @offices.nil?
        office = session[:office]
      elsif session[:company] != '0'
        @offices = @companies.first.offices.order(:name) if @offices.nil?
      else
        @offices = Office.order(:name) if @offices.nil?
      end

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = Project.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :project_code, no
          else
            with(:project_code).starting_with(no)
          end
        end
        if !company.blank?
          with :company_id, company
        end
        if !office.blank?
          with :office_id, office
        end
        data_accessor_for(Project).include = [:company, :office]
        order_by :sort_no, :asc
        paginate :per_page => Project.count
      end
      @project_report = @search.results

      current_projects = @project_report.blank? ? [0] : current_projects_for_index(@project_report)
      project = current_projects.to_a
      @project_ids = project

      @office = !office.blank? ? office : nil

      title = t("activerecord.models.project.few")
      from = Date.today.to_s

      respond_to do |format|
       # Render PDF
        if !@project_report.blank?
          format.pdf { send_data render_to_string,
                      filename: "#{title}_#{@from}.pdf",
                      type: 'application/pdf',
                      disposition: 'inline' }
          format.csv { send_data Project.to_csv(@project_report,@project_ids,@office),
                      filename: "#{title}_#{@from}.csv",
                      type: 'application/csv',
                      disposition: 'inline' }
        else
          format.csv { redirect_to projects_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to projects_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    private

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Project.where('project_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.project_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def companies_dropdown
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def offices_dropdown
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = session[:organization] != '0' ? Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name) : Office.order(:name)
      end
    end

    def companies_dropdown_edit(_organization)
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = _organization.companies.order(:name)
      end
    end

    def offices_dropdown_edit(_organization)
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = Office.joins(:company).where(companies: { organization_id: _organization }).order(:name)
      end
    end

    def offices_by_company(_company)
      Office.where(company_id: _company).order(:name)
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def projects_dropdown
      _array = []
      _projects = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
        else
          _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
        else
          _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
        end
      end

      # Project with Analytical Plan
      if !_projects.nil?
        _projects.each do |_r|
          if _r.has_analytical_plan?
            _array = _array << _r.read_attribute('id') unless _array.include? _r.read_attribute('id')
          end
        end
      end

      # Returning founded projects
      _projects = Project.where(id: _array).order(:project_code)
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
      # company
      if params[:WrkrCompany]
        session[:WrkrCompany] = params[:WrkrCompany]
      elsif session[:WrkrCompany]
        params[:WrkrCompany] = session[:WrkrCompany]
      end
      # office
      if params[:WrkrOffice]
        session[:WrkrOffice] = params[:WrkrOffice]
      elsif session[:WrkrOffice]
        params[:WrkrOffice] = session[:WrkrOffice]
      end
    end
  end
end
