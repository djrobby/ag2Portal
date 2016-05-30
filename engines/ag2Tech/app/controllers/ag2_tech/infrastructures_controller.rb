require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class InfrastructuresController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:in_update_company_textfield_from_office,
                                               :in_update_company_and_office_textfields_from_organization,
                                               :in_generate_code,
                                               :in_update_offices_select_from_company]

    # Update company text field at view from office select
    def in_update_company_textfield_from_office
      office = params[:id]
      @company = 0
      if office != '0'
        @office = Office.find(office)
        @company = @office.blank? ? 0 : @office.company
      end
      render json: @company
    end

    # Update company & office text fields at view from organization select
    def in_update_company_and_office_textfields_from_organization
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
    def in_generate_code
      organization = params[:organization]
      type = params[:type]

      # Builds code, if possible
      if organization == '$' || type == '$'
        code = '$err'
      else
        code = in_next_code(organization, type)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update offices from company select
    def in_update_offices_select_from_company
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

    #
    # Default Methods
    #
    # GET /infrastructures
    # GET /infrastructures.json
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

      @search = Infrastructure.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :code, no
          else
            with(:code).starting_with(no)
          end
        end
        if !company.blank?
          with :company_id, company
        end
        if !office.blank?
          with :office_id, office
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @infrastructures = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @infrastructures }
        format.js
      end
    end

    # GET /infrastructures/1
    # GET /infrastructures/1.json
    def show
      @breadcrumb = 'read'
      @infrastructure = Infrastructure.find(params[:id])
      @worker_orders = @infrastructure.work_orders.paginate(:page => params[:page], :per_page => per_page).order(:order_no)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @infrastructure }
      end
    end

    # GET /infrastructures/new
    # GET /infrastructures/new.json
    def new
      @breadcrumb = 'create'
      @infrastructure = Infrastructure.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @infrastructure_types = infrastructure_types_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @infrastructure }
      end
    end

    # GET /infrastructures/1/edit
    def edit
      @breadcrumb = 'update'
      @infrastructure = Infrastructure.find(params[:id])
      @companies = @infrastructure.organization.blank? ? companies_dropdown : companies_dropdown_edit(@infrastructure.organization)
      @offices = @infrastructure.organization.blank? ? offices_dropdown : offices_dropdown_edit(@infrastructure.organization_id)
      @infrastructure_types = @infrastructure.organization.blank? ? infrastructure_types_dropdown : infrastructure_types_dropdown_dropdown_edit(@infrastructure.organization_id)
    end

    # POST /infrastructures
    # POST /infrastructures.json
    def create
      @breadcrumb = 'create'
      @infrastructure = Infrastructure.new(params[:infrastructure])
      @infrastructure.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @infrastructure.save
          format.html { redirect_to @infrastructure, notice: crud_notice('created', @infrastructure) }
          format.json { render json: @infrastructure, status: :created, location: @infrastructure }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          format.html { render action: "new" }
          format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /infrastructures/1
    # PUT /infrastructures/1.json
    def update
      @breadcrumb = 'update'
      @infrastructure = Infrastructure.find(params[:id])
      @infrastructure.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @infrastructure.update_attributes(params[:infrastructure])
          format.html { redirect_to @infrastructure,
                        notice: (crud_notice('updated', @infrastructure) + "#{undo_link(@infrastructure)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @infrastructure.organization.blank? ? companies_dropdown : companies_dropdown_edit(@infrastructure.organization)
          @offices = @infrastructure.organization.blank? ? offices_dropdown : offices_dropdown_edit(@infrastructure.organization_id)
          @infrastructure_types = @infrastructure.organization.blank? ? infrastructure_types_dropdown : infrastructure_types_dropdown_dropdown_edit(@infrastructure.organization_id)
          format.html { render action: "edit" }
          format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /infrastructures/1
    # DELETE /infrastructures/1.json
    def destroy
      @infrastructure = Infrastructure.find(params[:id])

      respond_to do |format|
        if @infrastructure.destroy
          format.html { redirect_to infrastructures_url,
                      notice: (crud_notice('destroyed', @infrastructure) + "#{undo_link(@infrastructure)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to infrastructures_url, alert: "#{@infrastructure.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Infrastructure.where('code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.code
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

    def infrastructure_types_dropdown
      session[:organization] != '0' ? InfrastructureType.where(organization_id: session[:organization].to_i).order(:name) : InfrastructureType.order(:name)
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

    def infrastructure_types_dropdown_edit(_organization)
      if session[:organization] != '0'
        InfrastructureType.where(organization_id: session[:organization].to_i)
      else
        _organization.infrastructure_types.order(:name)
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
