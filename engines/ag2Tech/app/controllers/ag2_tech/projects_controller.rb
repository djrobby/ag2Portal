require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ProjectsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pr_update_company_textfield_from_office]
    
    # Update company text field at view from office select
    def pr_update_company_textfield_from_office
      @office = Office.find(params[:id])
      @company = Company.find(@office.company)

      respond_to do |format|
        format.html # pr_update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end

    #
    # Default Methods
    #
    # GET /projects
    # GET /projects.json
    def index
      manage_filter_state
      company = params[:Company]
      office = params[:Office]

      @search = Project.search do
        fulltext params[:search]
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

      # Initialize select_tags
      @companies = Company.order('name') if @companies.nil?
      @offices = Office.order('name') if @offices.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @projects }
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
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @project }
      end
    end
  
    # GET /projects/1/edit
    def edit
      @breadcrumb = 'update'
      @project = Project.find(params[:id])
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
    
    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # company
      if params[:Company]
        session[:Company] = params[:Company]
      elsif session[:Company]
        params[:Company] = session[:Company]
      end
      # office
      if params[:Office]
        session[:Office] = params[:Office]
      elsif session[:Office]
        params[:Office] = session[:Office]
      end
    end
  end
end
