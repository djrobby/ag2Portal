require_dependency "ag2_human/application_controller"

module Ag2Human
  class DepartmentsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:de_update_worker_select_from_company,
                                               :de_update_company_select_from_organization]
    # Helper methods for sorting
    helper_method :sort_column

    # Update worker select at view from company select
    def de_update_worker_select_from_company
      company = params[:department]
      if company != '0'
        @company = Company.find(company)
        @workers = @company.blank? ? Worker.order(:last_name, :first_name) : @company.workers.order(:last_name, :first_name)
      else
        @workers = Worker.order(:last_name, :first_name)
      end

      respond_to do |format|
        format.html # de_update_worker_select_from_company.html.erb does not exist! JSON only
        format.json { render json: @workers }
      end
    end

    # Update company select at view from organization select
    def de_update_company_select_from_organization
      organization = params[:department]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? Company.order(:name) : @organization.companies.order(:name)
      else
        @companies = Company.order(:name)
      end

      respond_to do |format|
        format.html # de_update_company_select_from_organization.html.erb does not exist! JSON only
        format.json { render json: @companies }
      end
    end

    #
    # Default Methods
    #
    # GET /departments
    # GET /departments.json
    def index
      if session[:organization] != '0'
        @departments = Department.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @departments = Department.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @departments }
      end
    end

    # GET /departments/1
    # GET /departments/1.json
    def show
      @breadcrumb = 'read'
      @department = Department.find(params[:id])
      @workers = @department.workers.paginate(:page => params[:page], :per_page => per_page).order('worker_code')

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
      @companies = Company.order(:name)
      @workers = Worker.order(:last_name, :first_name)

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @department }
      end
    end

    # GET /departments/1/edit
    def edit
      @breadcrumb = 'update'
      @department = Department.find(params[:id])
      @companies = @department.organization.blank? ? Company.order(:name) : @department.organization.companies.order(:name)
      @workers = @department.company.blank? ? Worker.order(:last_name, :first_name) : @department.company.workers.order(:last_name, :first_name)
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
          @companies = Company.order(:name)
          @workers = Worker.order(:last_name, :first_name)
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
          @companies = @department.organization.blank? ? Company.order(:name) : @department.organization.companies.order(:name)
          @workers = @department.company.blank? ? Worker.order(:last_name, :first_name) : @department.company.workers.order(:last_name, :first_name)
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
  end
end
