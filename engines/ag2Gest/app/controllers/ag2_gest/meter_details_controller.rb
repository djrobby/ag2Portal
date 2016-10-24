require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterDetailsController < ApplicationController
    
    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_details
    # GET /meter_details.json
    def index
      manage_filter_state
      @meter_details = MeterDetail.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_details }
        format.js
      end
    end
  
    # GET /meter_details/1
    # GET /meter_details/1.json
    def show

      @breadcrumb = 'read'
      @meter_detail = MeterDetail.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_detail }
      end
    end
  
    # GET /meter_details/new
    # GET /meter_details/new.json
    def new
      @breadcrumb = 'create'
      @meter_detail = MeterDetail.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_detail }
      end
    end
  
    # GET /meter_details/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_detail = MeterDetail.find(params[:id])
    end
  
    # POST /meter_details
    # POST /meter_details.json
    def create
      @breadcrumb = 'create'
      @meter_detail = MeterDetail.new(params[:meter_detail])
  
      respond_to do |format|
        if @meter_detail.save
          format.html { redirect_to @meter_detail, notice: t('activerecord.attributes.meter_detail.create') }
          format.json { render json: @meter_detail, status: :created, location: @meter_detail }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_detail.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /meter_details/1
    # PUT /meter_details/1.json
    def update
      @breadcrumb = 'update'
      @meter_detail = MeterDetail.find(params[:id])
  
      respond_to do |format|
        if @meter_detail.update_attributes(params[:meter_detail])
          format.html { redirect_to @meter_detail, notice: t('activerecord.attributes.meter_detail.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_detail.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /meter_details/1
    # DELETE /meter_details/1.json
    def destroy
      @meter_detail = MeterDetail.find(params[:id])
      @meter_detail.destroy
  
      respond_to do |format|
        format.html { redirect_to meter_details_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      MeterDetail.column_names.include?(params[:sort]) ? params[:sort] : "id"
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