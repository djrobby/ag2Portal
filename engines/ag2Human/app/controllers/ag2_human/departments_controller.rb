require_dependency "ag2_human/application_controller"

module Ag2Human
  class DepartmentsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /departments
    # GET /departments.json
    def index
      @departments = Department.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

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

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @department }
      end
    end

    # GET /departments/1/edit
    def edit
      @breadcrumb = 'update'
      @department = Department.find(params[:id])
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
          format.html { render action: "edit" }
          format.json { render json: @department.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /departments/1
    # DELETE /departments/1.json
    def destroy
      @department = Department.find(params[:id])
      @department.destroy

      respond_to do |format|
        format.html { redirect_to departments_url,
                      notice: (crud_notice('destroyed', @department) + "#{undo_link(@department)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Department.column_names.include?(params[:sort]) ? params[:sort] : "code"
    end
  end
end
