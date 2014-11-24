require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class VehiclesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /vehicles
    # GET /vehicles.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @vehicles = Vehicle.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @vehicles = Vehicle.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @vehicles }
        format.js
      end
    end
  
    # GET /vehicles/1
    # GET /vehicles/1.json
    def show
      @breadcrumb = 'read'
      @vehicle = Vehicle.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @vehicle }
      end
    end
  
    # GET /vehicles/new
    # GET /vehicles/new.json
    def new
      @breadcrumb = 'create'
      @vehicle = Vehicle.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @vehicle }
      end
    end
  
    # GET /vehicles/1/edit
    def edit
      @breadcrumb = 'update'
      @vehicle = Vehicle.find(params[:id])
    end
  
    # POST /vehicles
    # POST /vehicles.json
    def create
      @breadcrumb = 'create'
      @vehicle = Vehicle.new(params[:vehicle])
      @vehicle.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @vehicle.save
          format.html { redirect_to @vehicle, notice: crud_notice('created', @vehicle) }
          format.json { render json: @vehicle, status: :created, location: @vehicle }
        else
          format.html { render action: "new" }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /vehicles/1
    # PUT /vehicles/1.json
    def update
      @breadcrumb = 'update'
      @vehicle = Vehicle.find(params[:id])
      @vehicle.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @vehicle.update_attributes(params[:vehicle])
          format.html { redirect_to @vehicle,
                        notice: (crud_notice('updated', @vehicle) + "#{undo_link(@vehicle)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /vehicles/1
    # DELETE /vehicles/1.json
    def destroy
      @vehicle = Vehicle.find(params[:id])

      respond_to do |format|
        if @vehicle.destroy
          format.html { redirect_to vehicles_url,
                      notice: (crud_notice('destroyed', @vehicle) + "#{undo_link(@vehicle)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to vehicles_url, alert: "#{@vehicle.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Vehicle.column_names.include?(params[:sort]) ? params[:sort] : "registration"
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
