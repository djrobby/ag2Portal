require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /service_point_types
    def index
      manage_filter_state

      @service_point_types = ServicePointType.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_types }
        format.js
      end
    end

    # GET /service_point_types/1
    def show
      @breadcrumb = 'read'
      @service_point_type = ServicePointType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_type }
      end
    end

    # GET /service_point_types/new
    def new
      @breadcrumb = 'create'
      @service_point_type = ServicePointType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_type }
      end
    end

    # GET /service_point_types/1/edit
    def edit
      @breadcrumb = 'update'
      @service_point_type = ServicePointType.find(params[:id])
    end

    # POST /service_point_types
    def create
      @breadcrumb = 'create'
      @service_point_type = ServicePointType.new(params[:service_point_type])
      @service_point_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point_type.save
          format.html { redirect_to @service_point_type, notice: t('activerecord.attributes.service_point_type.create') }
          format.json { render json: @service_point_type, status: :created, location: @service_point_type }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /service_point_types/1
    def update
      @breadcrumb = 'update'
      @service_point_type = ServicePointType.find(params[:id])
      @service_point_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point_type.update_attributes(params[:service_point_type])
          format.html { redirect_to @service_point_type,
                        notice: (crud_notice('updated', @service_point_type) + "#{undo_link(@service_point_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point_types/1
    def destroy
      @service_point_type = ServicePointType.find(params[:id])

      respond_to do |format|
        if @service_point_type.destroy
          format.html { redirect_to service_point_types_url,
                      notice: (crud_notice('destroyed', @service_point_type) + "#{undo_link(@service_point_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to service_point_types_url, alert: "#{@service_point_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @service_point_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ServicePointType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
