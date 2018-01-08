require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class PreReadingsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    before_filter :get_pre_readings, only: [:impute_readings, :to_reading, :create, :to_pdf, :list, :list_q]
    skip_load_and_authorize_resource :only => [ :update,
                                                :destroy,
                                                :list,
                                                :to_pdf,
                                                :impute_readings,
                                                :new_impute,
                                                :to_reading,
                                                :update_reading_route_from_period
                                              ]
    def new_impute
      @breadcrumb = 'create'
      @billing_periods = billing_periods_dropdown.select{|b| !b.pre_readings.empty?}
      @reading_routes = reading_routes_dropdown.select{|r| !r.pre_readings.empty?}
      #@pre_readings = 1
    end

    def update_reading_route_from_period
      @billing_period = BillingPeriod.find(params[:id])
      @r_r = PreReading.select(:reading_route_id).where(project_id: current_projects_ids, billing_period_id: @billing_period.id).group(:reading_route_id)
      _rr = []
      @r_r.each do |r|
        _rr << r.reading_route_id
      end
      @reading_route = ReadingRoute.find(_rr)

      @json_data = { "reading_route" => @reading_route}

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    def impute_readings
      @pre_readings = @pre_readings.paginate(:page => params[:page], :per_page => per_page)
    end

    def list
      @pre_readings = @pre_readings.paginate(:page => params[:page], :per_page => per_page)
    end

    def list_q
      @pre_readings = @pre_readings.paginate(:page => params[:page], :per_page => per_page)
    end

    def show_list
      pre_readings = []

      @pre_readings.each do |pr|
        pre_readings << pr
      end
      @p_r = PreReading.where(id: pre_readings)
      @pre_readings = @p_r.order(:reading_route_id, :reading_sequence)

      respond_to do |format|
        format.html
        format.csv { render text: PreReading.to_csv(@pre_readings) }
      end
    end

    def to_reading
      @to_readings = @pre_readings
      # .select{|p| !p.reading_index.nil? or !p.reading_incidence_types.empty?}

      @to_readings.each do |pre_reading|
        redirect_to impute_readings_pre_readings_path(prereading: {reading_routes: @routes, period: @period, project: @project }), alert: I18n.t("ag2_gest.pre_readings.generate_error_incidence") and return if pre_reading.reading_incidence_types.empty? and pre_reading.reading_index.nil?
        # redirect_to impute_readings_pre_readings_path(prereading: {reading_routes: @routes, period: @period, project: @project }), alert: I18n.t("ag2_gest.pre_readings.generate_error_incidence") and return if pre_reading.reading_incidence_types.empty? and pre_reading.reading_index.nil? and pre_reading.reading_index_1.nil?
        reading = Reading.new( project_id: pre_reading.project_id,
                              billing_period_id: pre_reading.billing_period_id,
                              billing_frequency_id: pre_reading.billing_frequency_id,
                              reading_type_id: !pre_reading.reading_index.blank? ? pre_reading.reading_type_id : ReadingType::AUTO,
                              meter_id: pre_reading.meter_id,
                              subscriber_id: pre_reading.subscriber_id,
                              reading_route_id: pre_reading.reading_route_id,
                              reading_sequence: pre_reading.reading_sequence,
                              reading_variant: pre_reading.reading_variant,
                              # reading_date: !pre_reading.reading_date.blank? ? pre_reading.reading_date : BillingPeriod.find(@period).reading_ending_date,
                              reading_date: pre_reading.reading_date ,
                              reading_index: !pre_reading.reading_index.blank? ? pre_reading.reading_index : pre_reading.reading_index_1,
                              reading_index_1: pre_reading.reading_index_1,
                              reading_index_2: pre_reading.reading_index_2,
                              # reading_incidence_types: pre_reading.reading_incidence_types,
                              reading_1: pre_reading.reading_1,
                              reading_2: pre_reading.reading_2,
                              created_by: (current_user.id if !current_user.nil?))
        if reading.save
          pre_reading.reading_incidence_types.each do |i|
            ReadingIncidence.create(reading_id: reading.id, reading_incidence_type_id: i.id, created_at: Time.now)
          end
          pre_reading.destroy
        end
      end
      redirect_to impute_readings_pre_readings_path(prereading: {reading_routes: @routes, period: @period, project: @project })
    end

    def to_pdf
     #Ordenar array por código de ruta
     title = t("activerecord.models.pre_reading.few")
     respond_to do |format|
       format.pdf {
         send_data render_to_string, filename: "#{title}_#{Date.today}.pdf", type: 'application/pdf', disposition: 'inline'
       }
     end
    end

    # GET /prereadings
    # GET /prereadings.json
    def index
      @pre_readings = PreReading.includes(:reading_route, :billing_period)
                                .group(:reading_route_id, :billing_period_id)
                                .select('reading_route_id, billing_period_id, COUNT(*) COUNTER')
      # @pre_readings = PreReading.where(project_id: current_projects_ids)
      #                           .group_by{|p| [p.reading_route_id, p.billing_period_id]}
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

            # pervious_period_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.previous_period,billing_period.billing_frequency_id).try(:id)
            reading1 = set_reading_1_to_reading(s,s.meter,billing_period) #Reading.where(subscriber_id: s.id, reading_type_id: ReadingType::NORMAL, billing_period_id: pervious_period_id).first || s.readings.where(reading_type_id: 4).last #s.readings.find_by_reading_type_id(4)

            # pervious_year_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.year_period,billing_period.billing_frequency_id).try(:id)
            reading2 = set_reading_2_to_reading(s,s.meter,billing_period) #Reading.where(subscriber_id: s.id, reading_type_id: ReadingType::NORMAL, billing_period_id: pervious_year_id).first

            reading_billing_period = s.readings.where(billing_period_id: billing_period.id, reading_type_id: ReadingType::NORMAL)
            prereading_billing_period = s.pre_readings.where(billing_period_id: billing_period.id)

            if prereading_billing_period.blank? and reading_billing_period.blank? and !reading1.nil?
              pre_reading = PreReading.new(
                project_id: billing_period.project_id,
                billing_period_id: billing_period.id,
                billing_frequency_id: billing_period.billing_frequency_id,
                reading_type_id: ReadingType::NORMAL,
                meter_id: s.meter_id,
                subscriber_id: s.id,
                reading_route_id: s.reading_route_id,
                reading_sequence: s.reading_sequence,
                reading_variant: s.reading_variant,
                reading_1: reading1,
                reading_2: reading2,
                reading_index_1: reading1.try(:reading_index),
                reading_index_2: reading2.try(:reading_index),
                created_by: (current_user.id if !current_user.nil?)
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
      if params["pre_reading"]
        if !params["pre_reading"]["reading_index"]
          r_date = params[:pre_reading][:reading_date]
          @prereading.reading_index = !Reading.where(subscriber_id: @prereading.subscriber_id, reading_type_id: ReadingType.auto_registrable).where("reading_date < ?", r_date.to_date).order(:reading_date).last.blank? ? Reading.where(subscriber_id: @prereading.subscriber_id, reading_type_id: ReadingType.auto_registrable).where("reading_date < ?", r_date.to_date).order(:reading_date).last.reading_index : 0
          @prereading.reading_type_id = ReadingType::AUTO
        end
      end
      if params["incidence_type_ids"]
        # @prereading.reading_incidence_types.destroy_all
        # @prereading.reading_incidence_types << ReadingIncidenceType.where(id:params["incidence_type_ids"])
        @prereading.pre_reading_incidences.destroy_all
        params["incidence_type_ids"].each do |i|
          @prereading.pre_reading_incidences.create(pre_reading_id: @prereading.id, reading_incidence_type_id: i)
        end
      end
      # añdadir incidencia vuelta de contador y no existe. ID
      if params[:lap] == "true" and !@prereading.pre_reading_incidences.map(&:reading_incidence_type_id).include? 1
        @prereading.pre_reading_incidences.create(pre_reading_id: @prereading.id, reading_incidence_type_id: 1)
      end
      # Consumo Excesivo
      if params[:lapconexs] == "true" and !@prereading.pre_reading_incidences.map(&:reading_incidence_type_id).include? 21
        @prereading.pre_reading_incidences.create(pre_reading_id: @prereading.id, reading_incidence_type_id: 21)
      end
      # Bajo Consumo
      if params[:lapconbaj] == "true" and !@prereading.pre_reading_incidences.map(&:reading_incidence_type_id).include? 22
        @prereading.pre_reading_incidences.create(pre_reading_id: @prereading.id, reading_incidence_type_id: 22)
      end
      # fuera de plazo
      if params[:lapdate] == "true" and !@prereading.pre_reading_incidences.map(&:reading_incidence_type_id).include?(27)
        @prereading.pre_reading_incidences.create(pre_reading_id: @prereading.id, reading_incidence_type_id: 27)
      end
      respond_to do |format|
        if @prereading.update_attributes(params[:pre_reading])
          format.html { redirect_to @prereading, notice: t('activerecord.attribute.sale_offer.successfully') }
          format.json { render json: @prereading.to_json( include: :pre_reading_incidences ) }
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
      @pre_readings = PreReading.where(reading_route_id: @routes, billing_period_id: @period)
                                .includes(:reading_route, :billing_period)
                                .order(:reading_route_id, :reading_sequence)
    end

    def billing_periods_dropdown
      BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
    end

    def reading_routes_dropdown
      ReadingRoute.where(project_id: current_projects_ids).order("name")
    end

  end
end
