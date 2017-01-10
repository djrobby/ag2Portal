require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /water_connections
    def index
      manage_filter_state

      @water_connections = WaterConnection.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connections }
        format.js
      end
    end
  
    # GET /water_connections/1
    def show
      @breadcrumb = 'read'
      @water_connection = WaterConnection.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection }
      end
    end
  
    # GET /water_connections/new
    def new
      @breadcrumb = 'create'
      @water_connection = WaterConnection.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @water_connection }
      end
    end

    # GET /water_connections/1/edit
    def edit
      @breadcrumb = 'update'
      @water_connection = WaterConnection.find(params[:id])
    end
  
    # POST /water_connections
    def create
      @breadcrumb = 'create'
      @water_connection = WaterConnection.new(params[:water_connection])
      @water_connection.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @water_connection.save
          format.html { redirect_to @water_connection, notice: crud_notice('created', @water_connection) }
          format.json { render json: @water_connection, status: :created, location: @water_connection }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_connections/1
    def update
      @breadcrumb = 'update'
      @water_connection = WaterConnection.find(params[:id])
      @water_connection.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @water_connection.update_attributes(params[:water_connection])
          format.html { redirect_to @water_connection,
                        notice: (crud_notice('updated', @water_connection) + "#{undo_link(@water_connection)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_connections/1
    def destroy
      @water_connection = WaterConnection.find(params[:id])

      respond_to do |format|
        if @water_connection.destroy
          format.html { redirect_to water_connections_url,
                      notice: (crud_notice('destroyed', @water_connection) + "#{undo_link(@water_connection)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to water_connections_url, alert: "#{@water_connection.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @water_connection.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      WaterConnection.column_names.include?(params[:sort]) ? params[:sort] : "id"
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

