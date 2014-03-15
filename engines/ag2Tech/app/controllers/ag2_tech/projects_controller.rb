require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ProjectsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /projects
    # GET /projects.json
    def index
      @projects = Project.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
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

    def sort_column
      Project.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
