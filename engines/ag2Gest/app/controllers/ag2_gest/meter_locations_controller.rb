require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterLocationsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_locations
    # GET /meter_locations.json
    def index
      manage_filter_state
      @meter_locations = MeterLocation.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_locations }
        format.js
      end
    end

    # GET /meter_locations/1
    # GET /meter_locations/1.json
    def show

      @breadcrumb = 'read'
      @meter_location = MeterLocation.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_location }
      end
    end

    # GET /meter_locations/new
    # GET /meter_locations/new.json
    def new
      @breadcrumb = 'create'
      @meter_location = MeterLocation.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_location }
      end
    end

    # GET /meter_locations/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_location = MeterLocation.find(params[:id])
    end

    # POST /meter_locations
    # POST /meter_locations.json
    def create
      @breadcrumb = 'create'
      @meter_location = MeterLocation.new(params[:meter_location])
      @meter_location.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_location.save
          format.html { redirect_to @meter_location, notice: t('activerecord.attributes.meter_location.create') }
          format.json { render json: @meter_location, status: :created, location: @meter_location }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_location.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meter_locations/1
    # PUT /meter_locations/1.json
    def update
      @breadcrumb = 'update'
      @meter_location = MeterLocation.find(params[:id])
      @meter_location.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_location.update_attributes(params[:meter_location])
          format.html { redirect_to @meter_location,
                        notice: (crud_notice('updated', @meter_location) + "#{undo_link(@meter_location)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_location.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meter_locations/1
    # DELETE /meter_locations/1.json
    def destroy
      @meter_location = MeterLocation.find(params[:id])

      respond_to do |format|
        if @meter_location.destroy
          format.html { redirect_to meter_locations_url,
                      notice: (crud_notice('destroyed', @meter_location) + "#{undo_link(@meter_location)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meter_locations_url, alert: "#{@meter_location.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter_location.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      MeterLocation.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
