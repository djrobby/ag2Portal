require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ProjectsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pr_update_company_textfield_from_office,
                                               :pr_update_company_and_office_textfields_from_organization,
                                               :pr_generate_code,
                                               :pr_update_total_and_price]
    
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

    #
    # Default Methods
    #
    # GET /projects
    # GET /projects.json
    def index
      manage_filter_state
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

      @search = Project.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !company.blank?
          with :company_id, company
        end
        if !office.blank?
          with :office_id, office
        end
        order_by :project_code, :asc
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

    private

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
      _offices = Office.where(company_id: _company).order(:name)      
    end
    
    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
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
