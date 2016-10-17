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

      meter_model = params[:meter_models]
      if session[:office] != '0'
        @meters = Meter.where(office_id: session[:office]).paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
      elsif (session[:organization] != '0')
        @meters = Meter.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
      else
        @meters = Meter.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
      end

      meter_models_ids = @meters.map(&:meter_model_id).uniq #Get ids MeterModel associated
      @meter_models = MeterModel.where(id: meter_models_ids) #Get MeterModels Associated

      #@offices_ids = Company.find(session[:company]).offices.map(&:id) #Devuelve un solo array con todas las offices ids
      #@subscribers = Subscriber.where(office_id: @offices_ids).order(:subscriber_code) #Array de Subscribers
      #@meters = Meter.where(organization_id: session[:organization])

      #@search = Sunspot.search(Meter) do
        #with(:meter_model_id, 1)
        #with(:caliber_id, 1)
      #end

      #@search = Meter.search do
        #if !meter_model.blank?
          #with :meter_model_id, meter_model
        #end
        #order_by :sort_no, :asc
        #paginate :page => params[:page] || 1, :per_page => per_page
      #end

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
      @meter.organization_id = session[:organization]
      @meter.office_id = session[:office]
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
