require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TechniciansController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /technicians
    # GET /technicians.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @technicians = Technician.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @technicians = Technician.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @technicians }
        format.js
      end
    end

    # GET /technicians/1
    # GET /technicians/1.json
    def show
      @breadcrumb = 'read'
      @technician = Technician.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @technician }
      end
    end

    # GET /technicians/new
    # GET /technicians/new.json
    def new
      @breadcrumb = 'create'
      @technician = Technician.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @technician }
      end
    end

    # GET /technicians/1/edit
    def edit
      @breadcrumb = 'update'
      @technician = Technician.find(params[:id])
    end

    # POST /technicians
    # POST /technicians.json
    def create
      @breadcrumb = 'create'
      @technician = Technician.new(params[:technician])
      @technician.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @technician.save
          format.html { redirect_to @technician, notice: crud_notice('created', @technician) }
          format.json { render json: @technician, status: :created, location: @technician }
        else
          format.html { render action: "new" }
          format.json { render json: @technician.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /technicians/1
    # PUT /technicians/1.json
    def update
      @breadcrumb = 'update'
      @technician = Technician.find(params[:id])
      @technician.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @technician.update_attributes(params[:technician])
          format.html { redirect_to @technician,
                        notice: (crud_notice('updated', @technician) + "#{undo_link(@technician)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @technician.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /technicians/1
    # DELETE /technicians/1.json
    def destroy
      @technician = Technician.find(params[:id])
      @technician.destroy

      respond_to do |format|
        format.html { redirect_to technicians_url,
                      notice: (crud_notice('destroyed', @technician) + "#{undo_link(@technician)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Technician.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
