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

      code = params[:Code]
      model = params[:Model]
      brand = params[:Brand]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      meter_code = !meter_code.blank? && meter_code[0] == '%' ? inverse_no_search(meter_code) : meter_code

      @search = Meter.search do
        if session[:office] != '0'
          with :office_id, session[:office]
        elsif session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !code.blank?
          if code.class == Array
            with :meter_code, code
          else
            with(:meter_code).starting_with(code)
          end
        end
        if !model.blank?
          with :meter_model_id, model
        end
        if !brand.blank?
          with :meter_brand_id, brand
        end
        if !caliber.blank?
          with :caliber_id, caliber
        end
        if !from.blank?
          any_of do
            with(:purchase_date).greater_than(from)
            with :purchase_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:purchase_date).less_than(to)
            with :purchase_date, to
          end
        end
        order_by sort_column, sort_direction
        paginate :page => params[:page] || 1, :per_page => per_page || 10
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
      @details = @meter.meter_details.by_dates
      @readings = @meter.readings.by_period_date

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

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Meter.where('meter_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.meter_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    # Keeps filter state
    def manage_filter_state
      # Code
      if params[:Code]
        session[:Code] = params[:Code]
      elsif session[:Code]
        params[:Code] = session[:Code]
      end

      # Model
      if params[:Model]
        session[:Model] = params[:Model]
      elsif session[:Model]
        params[:Model] = session[:Model]
      end

      # Brand
      if params[:Brand]
        session[:Brand] = params[:Brand]
      elsif session[:Brand]
        params[:Brand] = session[:Brand]
      end

      # Caliber
      if params[:Caliber]
        session[:Caliber] = params[:Caliber]
      elsif session[:Caliber]
        params[:Caliber] = session[:Caliber]
      end

      # From
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end

      # To
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end
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
