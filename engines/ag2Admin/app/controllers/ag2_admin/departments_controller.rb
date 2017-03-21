require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class DepartmentsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:de_update_worker_select_from_company,
                                               :de_update_company_select_from_organization]
    # Helper methods for
    # => sorting
    # => allow edit (hide buttons)
    helper_method :sort_column, :cannot_edit

    # Update worker select at view from company select
    def de_update_worker_select_from_company
      company = params[:department]
      if company != '0'
        @company = Company.find(company)
        @workers = @company.blank? ? workers_dropdown : workers_by_company(@company)
      else
        @workers = workers_dropdown
      end
      render json: { "workers" => @workers }
    end

    # Update company select at view from organization select
    def de_update_company_select_from_organization
      organization = params[:department]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? companies_dropdown : @organization.companies.order(:name)
        @workers = @organization.blank? ? workers_dropdown : @organization.workers.order(:last_name, :first_name)
      else
        @companies = companies_dropdown
        @workers = workers_dropdown
      end
      @json_data = { "companies" => @companies, "workers" => @workers }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /departments
    # GET /departments.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @departments = Department.where(organization_id: session[:organization]).includes(:organization, :company).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @departments = Department.includes(:organization, :company).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @departments }
        format.js
      end
    end

    # GET /departments/1
    # GET /departments/1.json
    def show
      @breadcrumb = 'read'
      @department = Department.find(params[:id])
      @areas = @department.areas.paginate(:page => params[:page], :per_page => per_page).order('name')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @department }
      end
    end

    # GET /departments/new
    # GET /departments/new.json
    def new
      @breadcrumb = 'create'
      @department = Department.new
      @companies = companies_dropdown
      @workers = workers_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @department }
      end
    end

    # GET /departments/1/edit
    def edit
      @breadcrumb = 'update'
      @department = Department.find(params[:id])
      @companies = @department.organization.blank? ? companies_dropdown : companies_dropdown_edit(@department.organization)
      @workers = @department.company.blank? ? workers_dropdown : workers_dropdown_edit(@department.company_id)
    end

    # POST /departments
    # POST /departments.json
    def create
      @breadcrumb = 'create'
      @department = Department.new(params[:department])
      @department.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @department.save
          format.html { redirect_to @department, notice: crud_notice('created', @department) }
          format.json { render json: @department, status: :created, location: @department }
        else
          @companies = companies_dropdown
          @workers = workers_dropdown
          format.html { render action: "new" }
          format.json { render json: @department.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /departments/1
    # PUT /departments/1.json
    def update
      @breadcrumb = 'update'
      @department = Department.find(params[:id])
      @department.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @department.update_attributes(params[:department])
          format.html { redirect_to @department,
                        notice: (crud_notice('updated', @department) + "#{undo_link(@department)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @department.organization.blank? ? companies_dropdown : companies_dropdown_edit(@department.organization)
          @workers = @department.company.blank? ? workers_dropdown : workers_dropdown_edit(@department.company)
          format.html { render action: "edit" }
          format.json { render json: @department.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /departments/1
    # DELETE /departments/1.json
    def destroy
      @department = Department.find(params[:id])

      respond_to do |format|
        if @department.destroy
          format.html { redirect_to departments_url,
                      notice: (crud_notice('destroyed', @department) + "#{undo_link(@department)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to departments_url, alert: "#{@department.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @department.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Department.column_names.include?(params[:sort]) ? params[:sort] : "code"
    end

    def cannot_edit(_company)
      session[:company] != '0' && (_company != session[:company].to_i && !_company.blank?)
    end

    def companies_dropdown
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def workers_dropdown
      if session[:company] != '0'
        _workers = workers_by_company(session[:company].to_i)
      else
        _workers = session[:organization] != '0' ? Worker.where(organization_id: session[:organization].to_i).order(:last_name, :first_name) : Worker.order(:last_name, :first_name)
      end
    end

    def companies_dropdown_edit(_organization)
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = _organization.companies.order(:name)
      end
    end

    def workers_dropdown_edit(_company)
      if session[:company] != '0'
        _workers = workers_by_company(session[:company].to_i)
      else
        _workers = workers_by_company(_company)
      end
    end

    def workers_by_company(_company)
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:last_name, :first_name)
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
