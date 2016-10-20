crequire_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class PreReadingsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    before_filter :get_pre_readings, only: [:impute_readings, :to_reading, :create, :to_pdf, :list]
    skip_load_and_authorize_resource :only => [ :update,
                                                :destroy,
                                                :list,
                                                :to_pdf,
                                                :impute_readings,
                                                :new_impute,
                                                :to_reading
                                              ]
    def new_impute
      @breadcrumb = 'create'
      @billing_periods = billing_periods_dropdown.select{|b| !b.pre_readings.empty?}
      @reading_routes = reading_routes_dropdown.select{|r| !r.pre_readings.empty?}
    end

    def impute_readings
      @pre_readings = @pre_readings.paginate(:page => params[:page], :per_page => 30)
    end

    def list
      @pre_readings = @pre_readings.paginate(:page => params[:page], :per_page => 30)
    end

    def to_reading
      @to_readings = @pre_readings.select{|p| !p.reading_index.nil? or !p.reading_incidence_types.empty?}

      @to_readings.each do |pre_reading|
        reading = Reading.new( project_id: pre_reading.project_id,
                              billing_period_id: pre_reading.billing_period_id,
                              billing_frequency_id: pre_reading.billing_frequency_id,
                              reading_type_id: pre_reading.reading_type_id,
                              meter_id: pre_reading.meter_id,
                              subscriber_id: pre_reading.subscriber_id,
                              reading_route_id: pre_reading.reading_route_id,
                              reading_sequence: pre_reading.reading_sequence,
                              reading_variant: pre_reading.reading_variant,
                              reading_date: pre_reading.reading_date,
                              reading_index: pre_reading.reading_index || pre_reading.reading_index_1,
                              reading_index_1: pre_reading.reading_index_1,
                              reading_index_2: pre_reading.reading_index_2,
                              reading_incidence_types: pre_reading.reading_incidence_types,
                              reading_1: pre_reading.reading_1,
                              reading_2: pre_reading.reading_2 )
        if reading.save
          pre_reading.destroy
        end
      end
      redirect_to impute_readings_pre_readings_path(prereading: {reading_routes: @routes, period: @period, project: @project })
    end

    def to_pdf
     #Ordenar array por código de ruta
     respond_to do |format|
       format.pdf {
         send_data render_to_string, filename: "SCR.pdf", type: 'application/pdf', disposition: 'inline'
       }
     end
   end

    # GET /prereadings
    # GET /prereadings.json
    def index
      @pre_readings = PreReading.where(project_id: current_projects_ids)
                                .group_by{|p| [p.reading_route_id, p.billing_period_id]}
    end

    # GET /prereadings/1
    # GET /prereadings/1.json
    def show
      @breadcrumb = 'read'
      @prereading = PreReading.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @prereading }
      end
    end

    def show_test
      @breadcrumb = 'read'
    end

    # GET /prereadings/new
    # GET /prereadings/new.json
    def new
      @breadcrumb = 'create'
      @billing_periods = billing_periods_dropdown
      @reading_routes = reading_routes_dropdown
    end

    # GET /prereadings/1/edit
    def edit
      @prereading = PreReading.find(params[:id])
    end

    # POST /prereadings
    # POST /prereadings.json
    def create
      @breadcrumb = 'create'
      billing_period = BillingPeriod.find @period
      if billing_period #and @pre_readings.where(reading_type_id: 1).empty?
        subscribers = Subscriber.where(reading_route_id: @routes).availables.where("meter_id IS NOT NULL").order(&:reading_sequence).group_by(&:reading_route_id)
        subscribers.each do |subs|
          subs[1].each do |s|
            if s.pre_readings.where(billing_period_id: billing_period.id).blank?
              pervious_period_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.previous_period,billing_period.billing_frequency_id).try(:id)
              pervious_year_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.year_period,billing_period.billing_frequency_id).try(:id)
              reading1 = Reading.where(subscriber_id: s.id, reading_type_id: ReadingType::NORMAL, billing_period_id: pervious_period_id).first || s.readings.where(reading_type_id: 4).last #s.readings.find_by_reading_type_id(4)
              reading2 = Reading.where(subscriber_id: s.id, reading_type_id: ReadingType::NORMAL, billing_period_id: pervious_year_id).first
              pre_reading = PreReading.new(
                project_id: billing_period.project_id,
                billing_period_id: billing_period.id,
                billing_frequency_id: billing_period.billing_frequency_id,
                reading_type_id: 1,
                meter_id: s.meter_id,
                subscriber_id: s.id,
                reading_route_id: s.reading_route_id,
                reading_sequence: s.reading_sequence,
                reading_variant: s.reading_variant,
                reading_1: reading1,
                reading_2: reading2,
                reading_index_1: reading1.try(:reading_index),
                reading_index_2: reading2.try(:reading_index)
              )
              pre_reading.save(:validate => false)
            end
          end
        end
        redirect_to list_pre_readings_path(prereading: { reading_routes: @routes, period: billing_period.id})
        # redirect_to list_pre_readings_path(billing_period.id, @routes)
        # redirect_to impute_readings_pre_readings_path(prereading: { reading_routes: @routes, period: billing_period.id, project: [billing_period.project_id]})
      else
        redirect_to new_pre_reading_path, alert: t('activerecord.attributes.pre_reading.not_found')
      end
    end

    # PUT /prereadings/1
    # PUT /prereadings/1.json
    def update
      @breadcrumb = 'update'
      @prereading = PreReading.find(params[:id])
      if params["incidence_type_ids"]
        @prereading.reading_incidence_types.destroy_all
        @prereading.reading_incidence_types << ReadingIncidenceType.where(id:params["incidence_type_ids"])
      end
      # añdadir incidencia vuelta de contador y no existe. ID 4
      if params[:lap] == "true" and !@prereading.reading_incidence_types.map(&:id).include? 4
        @prereading.reading_incidence_types << ReadingIncidenceType.find(4)
      end
      respond_to do |format|
        if @prereading.update_attributes(params[:pre_reading])
          format.html { redirect_to @prereading, notice: t('activerecord.attribute.sale_offer.successfully') }
          format.json { render json: @prereading.to_json( include: :reading_incidence_types ) }
        else
          format.html { render action: "edit" }
          format.json { render json: @prereading.errors.full_messages.join(" ,"), status: :unprocessable_entity }
        end
      end
    end

    # DELETE /prereadings/1
    # DELETE /prereadings/1.json
    def destroy
      @prereading = PreReading.find(params[:id])
      @prereading.destroy

      respond_to do |format|
        format.json { head :no_content }
      end
    end

    private

    def get_pre_readings
      @routes = params[:prereading][:reading_routes].reject { |c| c.empty? } if params[:prereading][:reading_routes]
      @period = params[:prereading][:period]
      @pre_readings = PreReading.where(reading_route_id: @routes, billing_period_id: @period).all(:order => 'reading_route_id, reading_sequence')
    end

    def billing_periods_dropdown
      _billing_periods = BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
    end

    def reading_routes_dropdown
      _reading_routes = ReadingRoute.where(project_id: current_projects_ids).order("name")
    end

  end
end
