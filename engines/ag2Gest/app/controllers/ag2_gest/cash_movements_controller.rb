require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CashMovementsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:cm_update_selects_from_organization,
                                               :update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_country_textfield_from_region,
                                               :update_region_textfield_from_province,
                                               :cl_generate_code,
                                               :et_validate_fiscal_id_textfield,
                                               :cl_validate_fiscal_id_textfield,
                                               :check_client_depent_subscribers]
    # Helpers
    helper_method :sort_column

    # Update linked selects at view from organization select
    def cm_update_selects_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        if @organization.blank?
          projects = projects_dropdown
          offices = offices_dropdown
          companies = companies_dropdown
          types = cash_movement_types_dropdown
          payment_methods = cashier_payment_methods_dropdown
        else
          projects = projects_dropdown_edit(@organization.id, nil, nil, nil)
          offices = offices_dropdown_edit(@organization.id)
          companies = companies_dropdown_edit(@organization.id)
          types = cash_movement_types_dropdown_edit(@organization.id)
          payment_methods = cashier_payment_methods_dropdown_edit(@organization.id)
        end
      else
        projects = projects_dropdown
        offices = offices_dropdown
        companies = companies_dropdown
        types = types_dropdown
        payment_methods = payment_methods_dropdown
      end
      # Arrays
      projects = projects_array(projects)
      offices = offices_array(offices)
      companies = companies_array(companies)
      types = types_array(types)
      payment_methods = payment_methods_array(payment_methods)
      # Setup JSON
      @json_data = { "project" => projects, "office" => offices,
                     "company" => companies, "type" => types,
                     "payment_method" => payment_methods }
      render json: @json_data
    end

    # Update linked selects at view from project select
    def cm_update_selects_from_project
      project = params[:prj]
      office_id = 0
      company_id = 0
      if project != '0'
        @project = Project.find(project)
        if @project.blank?
          offices = offices_dropdown
          companies = companies_dropdown
        else
          offices = @project.office
          office_id = offices.id
          companies = @project.company
          company_id = companies.id
        end
      else
        offices = offices_dropdown
        companies = companies_dropdown
      end
      # Arrays
      offices = offices_array(offices)
      companies = companies_array(companies)
      # Setup JSON
      @json_data = { "office" => offices, "company" => companies,
                     "office_id" => office_id, "company_id" => company_id }
      render json: @json_data
    end

    # Update linked selects at view from office select
    def cm_update_selects_from_office
      office = params[:off]
      company_id = 0
      if office != '0'
        @office = Office.find(office)
        if @office.blank?
          companies = companies_dropdown
        else
          companies = @office.company
          company_id = companies.id
        end
      else
        companies = companies_dropdown
      end
      # Arrays
      companies = companies_array(companies)
      # Setup JSON
      @json_data = { "company" => companies, "company_id" => company_id }
      render json: @json_data
    end

    # Format numbers properly
    def cm_format_number
      num = params[:num].to_f / 100
      type = params[:typ]
      if type != '0'
        @type = CashMovementType.find(type)
        if !@type.blank?
          num = num * (-1) if (@type.type_id == CashMovementType.OUTFLOW && num > 0)
        end
      end
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /cash_movements
    # GET /cash_movements.json
    def index
      manage_filter_state

      project = params[:Project]
      office = params[:Office]
      company = params[:Company]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = current_projects if @projects.nil?
      @project_ids = current_projects_ids
      @offices = current_offices if @offices.nil?
      @companies = companies_dropdown if @companies.nil?

      @search = CashMovement.search do
        with :project_id, current_projects_ids unless current_projects_ids.blank?
        if !params[:search].blank?
          fulltext params[:search]
        end
        if !project.blank?
          with :project_id, project
        end
        if !office.blank?
          with :office_id, office
        end
        if !company.blank?
          with :company_id, company
        end
        if !from.blank?
          any_of do
            with(:movement_date).greater_than(from)
            with :movement_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:movement_date).less_than(to)
            with :movement_date, to
          end
        end
        order_by sort_column, "desc"
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @cash_movements = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @cash_movements }
        format.js
      end
    end

    # GET /cash_movements/1
    # GET /cash_movements/1.json
    def show
      @breadcrumb = 'read'
      @cash_movement = CashMovement.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @cash_movement }
      end
    end

    # GET /cash_movements/new
    # GET /cash_movements/new.json
    def new
      @breadcrumb = 'create'
      @cash_movement = CashMovement.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @projects = projects_dropdown
      @cash_movement_types = cash_movement_types_dropdown
      @cashier_payment_methods = cashier_payment_methods_dropdown
      @charge_accounts = []

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @cash_movement }
      end
    end

    # GET /cash_movements/1/edit
    def edit
      @breadcrumb = 'update'
      @cash_movement = CashMovement.find(params[:id])
      if @cash_movement.organization.blank?
        @companies = companies_dropdown
        @offices = offices_dropdown
        @projects = projects_dropdown
      else
        @companies = companies_dropdown_edit(@cash_movement.organization)
        @offices = offices_dropdown_edit(@cash_movement.organization_id)
        @projects = projects_dropdown_edit(@cash_movement.organization_id, @cash_movement.company_id, @cash_movement.office_id, @cash_movement.project_id)
      end
      @cash_movement_types = cash_movement_types_dropdown
      @cashier_payment_methods = cashier_payment_methods_dropdown
      @charge_accounts = []
    end

    # POST /cash_movements
    # POST /cash_movements.json
    def create
      @breadcrumb = 'create'
      @cash_movement = CashMovement.new(params[:cash_movement])
      @cash_movement.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement.save
          format.html { redirect_to @cash_movement, notice: crud_notice('created', @cash_movement) }
          format.json { render json: @cash_movement, status: :created, location: @cash_movement }
        else
          format.html { render action: "new" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /cash_movements/1
    # PUT /cash_movements/1.json
    def update
      @breadcrumb = 'update'
      @cash_movement = CashMovement.find(params[:id])
      @cash_movement.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement.update_attributes(params[:cash_movement])
          format.html { redirect_to @cash_movement,
                        notice: (crud_notice('updated', @cash_movement) + "#{undo_link(@cash_movement)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /cash_movements/1
    # DELETE /cash_movements/1.json
    def destroy
      @cash_movement = CashMovement.find(params[:id])

      respond_to do |format|
        if @cash_movement.destroy
          format.html { redirect_to cash_movements_url,
                      notice: (crud_notice('destroyed', @cash_movement) + "#{undo_link(@cash_movement)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to cash_movements_url, alert: "#{@cash_movement.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      CashMovement.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def companies_dropdown
      if session[:company] != '0'
        Company.where(id: session[:company].to_i)
      elsif session[:organization] != '0'
        Company.where(organization_id: session[:organization].to_i).order(:name)
      else
        Company.order(:name)
      end
    end

    def offices_dropdown
      if session[:office] != '0'
        Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        offices_by_company(session[:company].to_i)
      else
        session[:organization] != '0' ? Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name) : Office.order(:name)
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

    def projects_dropdown
      _array = []
      _projects = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).by_code
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
        else
          _projects = Project.where(company_id: session[:company].to_i).by_code
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
        else
          _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).by_code : Project.by_code
        end
      end

      # Returning founded projects
      ret_array(_array, _projects, 'id')
      _projects = Project.where(id: _array).by_code
    end

    def projects_dropdown_edit(_organization, _company, _office, _project)
      _projects = projects_dropdown
      if _projects.blank?
        if !_office.blank?
          _projects = Project.where(office_id: _office).by_code
        elsif !_company.blank?
          _offices = current_user.offices
          if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
            _projects = Project.where('company_id = ? AND office_id IN (?)', _company, _offices).by_code
          else
            _projects = Project.where(company_id: _company).by_code
          end
        elsif !_organization.blank?
          _offices = current_user.offices
          _companies = current_user.companies
          if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
            _projects = Project.where('organization_id = ? AND company_id IN (?) AND office_id IN (?)', _organization, _companies, _offices)
          else
            _projects = Project.where(organization_id: _organization).by_code
          end
        elsif !_project.blank?
          _projects = Project.where(id: _project)
        else
          _offices = current_user.offices
          _companies = current_user.companies
          if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
            _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
          else
            _projects = Project.by_code
          end
        end
      end
      _projects
    end

    def cashier_payment_methods_dropdown
      session[:organization] != '0' ? PaymentMethod.collections_by_organization_used_by_cashier(session[:organization].to_i) : PaymentMethod.collections_used_by_cashier
    end

    def cashier_payment_methods_dropdown_edit(_organization=nil)
      !_organization.nil? ? PaymentMethod.collections_by_organization_used_by_cashier(_organization) : PaymentMethod.collections_used_by_cashier
    end

    def cash_movement_types_dropdown
      session[:organization] != '0' ? CashMovementType.belongs_to_organization(session[:organization].to_i) : CashMovementType.by_code
    end

    def cash_movement_types_dropdown_edit(_organization)
      !_organization.nil? ? CashMovementType.belongs_to_organization(_organization) : CashMovementType.by_code
    end

    def projects_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def offices_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def companies_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.name]
      end
      _array
    end

    def types_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def payment_methods_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label]
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

      # Project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end

      # Office
      if params[:Office]
        session[:Office] = params[:Office]
      elsif session[:Office]
        params[:Office] = session[:Office]
      end

      # Company
      if params[:Company]
        session[:Company] = params[:Company]
      elsif session[:Company]
        params[:Company] = session[:Company]
      end

      # From
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end

      # To
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end

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
