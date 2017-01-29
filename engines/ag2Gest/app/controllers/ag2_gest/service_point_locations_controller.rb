require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointLocationsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /service_point_locations
    def index
      manage_filter_state

      @service_point_locations = ServicePointLocation.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_locations }
        format.js
      end
    end

    # GET /service_point_locations/1
    def show
      @breadcrumb = 'read'
      @service_point_location = ServicePointLocation.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_location }
      end
    end

    # GET /service_point_locations/new
    def new
      @breadcrumb = 'create'
      @service_point_location = ServicePointLocation.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_location }
      end
    end

    # GET /service_point_locations/1/edit
    def edit
      @breadcrumb = 'update'
      @service_point_location = ServicePointLocation.find(params[:id])
    end

    # POST /service_point_locations
    def create
      @breadcrumb = 'create'
      @service_point_location = ServicePointLocation.new(params[:service_point_location])
      @service_point_location.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point_location.save
          format.html { redirect_to @service_point_location, notice: t('activerecord.attributes.service_point_location.create') }
          format.json { render json: @service_point_location, status: :created, location: @service_point_location }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_location.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /service_point_locations/1
    def update
      @breadcrumb = 'update'
      @service_point_location = ServicePointLocation.find(params[:id])
      @service_point_location.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point_location.update_attributes(params[:service_point_location])
          format.html { redirect_to @service_point_location,
                        notice: (crud_notice('updated', @service_point_location) + "#{undo_link(@service_point_location)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_location.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point_locations/1
    def destroy
      @service_point_location = ServicePointLocation.find(params[:id])

      respond_to do |format|
        if @service_point_location.destroy
          format.html { redirect_to service_point_locations_url,
                      notice: (crud_notice('destroyed', @service_point_location) + "#{undo_link(@service_point_location)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to service_point_locations_url, alert: "#{@service_point_location.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @service_point_location.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ServicePointLocation.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
