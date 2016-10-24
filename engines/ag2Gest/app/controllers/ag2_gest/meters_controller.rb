require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MetersController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meters
    # GET /meters.json
    def index

      manage_filter_state
      @search = Meter.search do
        if session[:office] != '0'
          with :office_id, session[:office]
        elsif session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !params[:meter_code].blank?
          fulltext params[:meter_code]
        end
        if !params[:meter_model_id].blank?
          with :meter_model_id, params[:meter_model_id]
        end
        if !params[:caliber_id].blank?
          with :caliber_id, params[:caliber_id]
        end
        order_by sort_column, sort_direction
        paginate :page => params[:page] || 1, :per_page => 10
      end

      @meters = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meters }
        format.js
      end
    end

    # GET /meters/1
    # GET /meters/1.json
    def show
      @breadcrumb = 'read'
      @meter = Meter.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter }
      end
    end

    # GET /meters/new
    # GET /meters/new.json
    def new
      @breadcrumb = 'create'
      @meter = Meter.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter }
      end
    end

    # GET /meters/1/edit
    def edit
      @breadcrumb = 'update'
      @meter = Meter.find(params[:id])
    end

    # POST /meters
    # POST /meters.json
    def create
      @breadcrumb = 'create'
      @meter = Meter.new(params[:meter])
      office = Office.find(params[:meter][:office_id])
      @meter.company_id = office.company_id
      @meter.organization_id = office.try(:company).try(:organization_id)
      @meter.created_by = current_user.id if !current_user.nil?
      respond_to do |format|
        if @meter.save
          format.html { redirect_to @meter, notice: t('activerecord.attributes.meter.create') }
          format.json { render json: @meter, status: :created, location: @meter }
        else
          format.html { render action: "new" }
          format.json { render json: @meter.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meters/1
    # PUT /meters/1.json
    def update
      @breadcrumb = 'update'
      @meter = Meter.find(params[:id])
      @meter.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter.update_attributes(params[:meter])
          format.html { redirect_to @meter, notice: t('activerecord.attributes.meter.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meters/1
    # DELETE /meters/1.json
    def destroy
      @meter = Meter.find(params[:id])
      @meter.destroy

      respond_to do |format|
        format.html { redirect_to meters_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Meter.column_names.include?(params[:sort]) ? params[:sort] : "meter_code"
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
