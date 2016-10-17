require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /readings
    # GET /readings.json
    def index
      #manage_filter_state

      manage_filter_state

      meter = params[:Meter]
      @meters = meters_dropdown if @meter.nil?
      #@readings = @search.results
      @readings = PreReading.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @readings }
      end
    end

    # GET /readings/1
    # GET /readings/1.json
    def show

      @breadcrumb = 'read'
      @reading = Reading.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading }
      end
    end

    # GET /readings/new
    # GET /readings/new.json
    def new
      @breadcrumb = 'create'
      @reading = Reading.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading }
      end
    end

    # GET /readings/1/edit
    def edit
      @breadcrumb = 'update'
      @reading = Reading.find(params[:id])
    end

    # POST /readings
    # POST /readings.json
    def create

      @breadcrumb = 'create'
      #All associations
      @subscriber = Subscriber.find(params[:reading][:subscriber_id])
      @meter = Meter.find(params[:reading][:meter_id])
      @project = Project.find(params[:reading][:project_id])
      @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])

      @billing_frequency = BillingFrequency.find(params[:reading][:billing_frequency_id])
      @reading_route = ReadingRoute.find(params[:reading][:reading_route_id])

      @reading_type = ReadingType.find(params[:reading][:reading_type_id])

      @reading_incidence_types = params[:incidence_type_ids]

      #Update JavaScript
      if !@reading_incidence_types.blank? #True
        @reading_incidence_types = ReadingIncidenceType.where(id: @reading_incidence_types).map(&:name)
      else #False
        @reading_incidence_types = []
      end

      #@reading_incidence_types = ReadingIncidenceType.find(params[:incidence_type_ids])
      #@reading.reading_incidence_types.create(params[:incidence_type_ids])
      #@reading = Reading.new(params[:reading].merge(:reading_incidence_type_ids => params[:incidence_type_ids]))
      #params[:incidence_type_ids].each do |reading_incidence_type_id|
        #@reading.reading_incidence_types.build(reading_incidence_type_id: reading_incidence_type_id)
      #end
      #params.require(:reading).permit(:subscriber_id, :meter_id, :billing_frequency_id, :reading_route_id, :project_id, :billing_period_id, :reading_type_id, :reading_date, :reading_index, {:reading_incidence_types_ids => params[:incidence_type_ids]})

      @reading = Reading.new(params[:reading])

      if params[:incidence_type_ids].blank? #[]

      else
        @my_read_inci_type = ReadingIncidenceType.find(params[:incidence_type_ids])
        @reading.reading_incidence_types << @my_read_inci_type
      end

      if @reading.save

        response_hash = {reading: @reading}
        response_hash[:project] = @project
        response_hash[:subscriber] = @subscriber
        response_hash[:meter] = @meter
        response_hash[:billing_period] = @billing_period
        response_hash[:billing_frequency] = @billing_frequency
        response_hash[:reading_type] = @reading_type
        response_hash[:reading_route] = @reading_route
        response_hash[:reading_incidence_types] = @reading_incidence_types

        respond_to do |format|
          format.html { redirect_to @reading.subscriber, notice: crud_notice('created', @reading) }
          format.json { render json: response_hash, status: :created, location: @reading.subscriber }
        end
      else
        respond_to do |format|
          format.html { redirect_to @reading.subscriber, notice: crud_notice('created', @reading) }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end


#      respond_to do |format|
#        if @reading.save
#          format.html { redirect_to @reading, notice: t('activerecord.attributes.reading.create') }
#          format.json { render json: @reading, status: :created, location: @reading }
#        else
#          format.html { render action: "new" }
#          format.json { render json: @reading.errors, status: :unprocessable_entity }
#        end
#      end
    end

    # PUT /readings/1
    # PUT /readings/1.json
    def update
      @breadcrumb = 'update'
      @reading = Reading.find(params[:id])
      incidences = params[:reading][:reading_incidences_ids]
      params[:reading].delete :reading_incidences_ids

      @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id incidences

      respond_to do |format|
        if @reading.update_attributes(params[:reading])
          format.html { redirect_to @reading, notice: t('activerecord.attributes.reading.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /readings/1
    # DELETE /readings/1.json
    def destroy
      @reading = Reading.find(params[:id])
      @reading.destroy

      respond_to do |format|
        format.html { redirect_to readings_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Reading.column_names.include?(params[:sort]) ? params[:sort] : "readings"
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

    def meters_dropdown
      _meters = Meter.order(:meter_code)
    end

    def manage_filter_state
      # id_fiscal
      if params[:Meter]
        session[:Meter] = params[:Meter]
      elsif session[:Meter]
        params[:Meter] = session[:Meter]
      end
    end

  end
end
