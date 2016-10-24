require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointPurposesController < ApplicationController
    
    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /service_point_purposes
    def index
      manage_filter_state
      
      @service_point_purposes = ServicePointPurpose.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_point_purposes }
        format.js
      end
    end

    # GET /service_point_purposes/1
    def show
      @breadcrumb = 'read'
      @service_point_purpose = ServicePointPurpose.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point_purpose }
      end
    end

    # GET /service_point_purposes/new
    def new
      @breadcrumb = 'create'
      @service_point_purpose = ServicePointPurpose.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point_purpose }
      end
    end

    # GET /service_point_purposes/1/edit
    def edit
      @breadcrumb = 'update'
      @service_point_purpose = ServicePointPurpose.find(params[:id])
    end

    # POST /service_point_purposes
    def create
      @breadcrumb = 'create'
      @service_point_purpose = ServicePointPurpose.new(params[:service_point_purpose])
  
      respond_to do |format|
        if @service_point_purpose.save
          format.html { redirect_to @service_point_purpose, notice: t('activerecord.attributes.service_point_purpose.create') }
          format.json { render json: @service_point_purpose, status: :created, location: @service_point_purpose }
        else
          format.html { render action: "new" }
          format.json { render json: @service_point_purpose.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /service_point_purposes/1
    def update
      @breadcrumb = 'update'
      @service_point_purpose = ServicePointPurpose.find(params[:id])
  
      respond_to do |format|
        if @service_point_purpose.update_attributes(params[:service_point_purpose])
          format.html { redirect_to @service_point_purpose, notice: t('activerecord.attributes.service_point_purpose.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point_purpose.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point_purposes/1
    def destroy
      @service_point_purpose = ServicePointPurpose.find(params[:id])
      @service_point_purpose.destroy
  
      respond_to do |format|
        format.html { redirect_to service_point_purposes_url }
        format.json { head :no_content }
      end
    end

    private
    
    def sort_column
      ServicePointPurpose.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
