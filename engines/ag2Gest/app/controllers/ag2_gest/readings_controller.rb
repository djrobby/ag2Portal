require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /readings
    # GET /readings.json
    def index

      manage_filter_state

      subscriber = params[:Subscriber]
      meter = params[:Meter]
      reading_date = params[:ReadingDate]
      period = params[:Period]
      route = params[:Route]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @subscribers = subscribers_dropdown if @subscribers.nil?
      @meters = meters_dropdown if @meters.nil?
      @periods = periods_dropdown if @periods.nil?
      @routes = routes_dropdown if @routes.nil?

      @search = Reading.search do
        with :project_id, current_projects_ids
        if !subscriber.blank?
          with :subscriber_id, subscriber
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !from.blank?
          any_of do
            with(:reading_date).greater_than(from)
            with :reading_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:reading_date).less_than(to)
            with :reading_date, to
          end
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !route.blank?
          with :reading_route_id, route
        end
        order_by :sort_no, :desc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @readings = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @readings }
        format.js
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
      @subscriber = @reading.subscriber
      @reading.destroy

      respond_to do |format|
        format.html { redirect_to subscriber_path(@subscriber) }
        format.json { head :no_content }
      end
    end

    private

    def subscribers_dropdown
      # Subscribers by current office, company or organization
      if current_offices_ids.blank?
        Subscriber.order(:subscriber_code)
      else
        Subscriber.where(office_id: current_offices_ids).order(:subscriber_code)
      end
    end

    def meters_dropdown
      # Meters by current office, company or organization
      if current_offices_ids.blank?
        Meter.order(:meter_code)
      else
        Meter.where(office_id: current_offices_ids).order(:meter_code)
      end
    end

    def periods_dropdown
      if current_projects.blank?
        BillingPeriod.order(:period)
      else
        BillingPeriod.where(project_id: current_projects_ids).order(:period)
      end
    end

    def routes_dropdown
      if current_projects.blank?
        ReadingRoute.order(:routing_code)
      else
        ReadingRoute.where(project_id: current_projects_ids).order(:routing_code)
      end
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:Subscriber]
        session[:Subscriber] = params[:Subscriber]
      elsif session[:Subscriber]
        params[:Subscriber] = session[:Subscriber]
      end
      # no
      if params[:Meter]
        session[:Meter] = params[:Meter]
      elsif session[:Meter]
        params[:Meter] = session[:Meter]
      end
      # project
      if params[:ReadingDate]
        session[:ReadingDate] = params[:ReadingDate]
      elsif session[:ReadingDate]
        params[:ReadingDate] = session[:ReadingDate]
      end
      # type
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
      # status
      if params[:Route]
        session[:Route] = params[:Route]
      elsif session[:Route]
        params[:Route] = session[:Route]
      end
    end

  end
end
