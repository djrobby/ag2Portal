require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class AreasController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /areas
    # GET /areas.json
    def index
      @areas = Area.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
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
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @area }
      end
    end
  
    # GET /areas/1/edit
    def edit
      @breadcrumb = 'update'
      @area = Area.find(params[:id])
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
  end
end
