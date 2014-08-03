require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class AreasController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ar_update_worker_select_from_department]
    # Helper methods for
    # => sorting
    # => allow edit (hide buttons)
    helper_method :sort_column, :cannot_edit

    # Update worker select at view from department select
    def ar_update_worker_select_from_department
      department = params[:department]
      if department != '0'
        @department = Department.find(department)
        @workers = @department.company.blank? ? Worker.order(:last_name, :first_name) : @department.company.workers.order(:last_name, :first_name)
      else
        @workers = Worker.order(:last_name, :first_name)
      end

      respond_to do |format|
        format.html # ar_update_worker_select_from_department.html.erb does not exist! JSON only
        format.json { render json: @workers }
      end
    end

    #
    # Default Methods
    #
    # GET /areas
    # GET /areas.json
    def index
      if session[:organization] != '0'
        # OCO organization active
        @areas = Area.joins(:department).where(departments: { organization_id: session[:organization] }).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        # OCO inactive
        @areas = Area.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @areas }
      end
    end
  
    # GET /areas/1
    # GET /areas/1.json
    def show
      @breadcrumb = 'read'
      @area = Area.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @area }
      end
    end
  
    # GET /areas/new
    # GET /areas/new.json
    def new
      @breadcrumb = 'create'
      @area = Area.new
      @workers = Worker.order(:last_name, :first_name)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @area }
      end
    end
  
    # GET /areas/1/edit
    def edit
      @breadcrumb = 'update'
      @area = Area.find(params[:id])
      @workers = @area.department.company.blank? ? Worker.order(:last_name, :first_name) : @area.department.company.workers.order(:last_name, :first_name)
    end
  
    # POST /areas
    # POST /areas.json
    def create
      @breadcrumb = 'create'
      @area = Area.new(params[:area])
      @area.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @area.save
          format.html { redirect_to @area, notice: crud_notice('created', @area) }
          format.json { render json: @area, status: :created, location: @area }
        else
          @workers = Worker.order(:last_name, :first_name)
          format.html { render action: "new" }
          format.json { render json: @area.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /areas/1
    # PUT /areas/1.json
    def update
      @breadcrumb = 'update'
      @area = Area.find(params[:id])
      @area.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @area.update_attributes(params[:area])
          format.html { redirect_to @area,
                        notice: (crud_notice('updated', @area) + "#{undo_link(@area)}").html_safe }
          format.json { head :no_content }
        else
          @workers = @area.department.company.blank? ? Worker.order(:last_name, :first_name) : @area.department.company.workers.order(:last_name, :first_name)
          format.html { render action: "edit" }
          format.json { render json: @area.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /areas/1
    # DELETE /areas/1.json
    def destroy
      @area = Area.find(params[:id])

      respond_to do |format|
        if @area.destroy
          format.html { redirect_to areas_url,
                      notice: (crud_notice('destroyed', @area) + "#{undo_link(@area)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to areas_url, alert: "#{@area.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @area.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Area.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
    
    def cannot_edit(_department)
      session[:company] != '0' && (_department.company_id != session[:company].to_i && !_department.company.blank?)
    end
  end
end
