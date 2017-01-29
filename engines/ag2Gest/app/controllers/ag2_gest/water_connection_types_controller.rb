require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /water_connection_types
    def index
      manage_filter_state

      @water_connection_types = WaterConnectionType.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connection_types }
        format.js
      end
    end

    # GET /water_connection_types/1
    def show
      @breadcrumb = 'read'
      @water_connection_type = WaterConnectionType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection_type }
      end
    end

    # GET /water_connection_types/new
    def new
      @breadcrumb = 'create'
      @water_connection_type = WaterConnectionType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_connection_type }
      end
    end

    # GET /water_connection_types/1/edit
    def edit
      @breadcrumb = 'update'
      @water_connection_type = WaterConnectionType.find(params[:id])
    end

    # POST /water_connection_types
    def create
      @breadcrumb = 'create'
      @water_connection_type = WaterConnectionType.new(params[:water_connection_type])
      @water_connection_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @water_connection_type.save
          format.html { redirect_to @water_connection_type, notice: crud_notice('created', @water_connection_type) }
          format.json { render json: @water_connection_type, status: :created, location: @water_connection_type }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /water_connection_types/1
    def update
      @breadcrumb = 'update'
      @water_connection_type = WaterConnectionType.find(params[:id])
      @water_connection_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @water_connection_type.update_attributes(params[:water_connection_type])
          format.html { redirect_to @water_connection_type,
                        notice: (crud_notice('updated', @water_connection_type) + "#{undo_link(@water_connection_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /water_connection_types/1
    def destroy
      @water_connection_type = WaterConnectionType.find(params[:id])

      respond_to do |format|
        if @water_connection_type.destroy
          format.html { redirect_to water_connection_types_url,
                      notice: (crud_notice('destroyed', @water_connection_type) + "#{undo_link(@water_connection_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to water_connection_types_url, alert: "#{@water_connection_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @water_connection_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      WaterConnectionType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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

