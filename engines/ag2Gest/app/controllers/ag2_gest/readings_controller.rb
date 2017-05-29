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
      # @subscribers = subscribers_dropdown if @subscribers.nil?
      # @meters = meters_dropdown if @meters.nil?
      @periods = periods_dropdown if @periods.nil?
      @routes = routes_dropdown if @routes.nil?

      @search = Reading.search do
        with :project_id, current_projects_ids unless current_projects_ids.blank?
        if !subscriber.blank?
          fulltext subscriber
        end
        if !meter.blank?
          fulltext meter
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
        order_by :reading_date, :desc
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
      unless @reading.billable?
        url_return = session[:return_to_subscriber_url].blank? ? @reading : session[:return_to_subscriber_url]
        redirect_to url_return, alert: "No se puede modificar lecturas facturadas" and return
      end
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
      @reading_exits = Reading.where( meter_id: params[:reading][:meter_id],
                                      project_id: params[:reading][:project_id],
                                      billing_period_id: params[:reading][:billing_period_id],
                                      reading_type_id: params[:reading][:reading_type_id]).
                              where("date(reading_date) = ?", params[:reading][:reading_date].split(' ')[0].to_date)


      if @reading_exits.blank?

        @reading = Reading.new(params[:reading])
        if !params[:incidence_type_ids].blank? #[]
          @my_read_inci_type = ReadingIncidenceType.where(id: params[:incidence_type_ids])
          @reading.reading_incidence_types << @my_read_inci_type
        end

        rdg_1 = set_reading_1_to_reading(@subscriber,@meter,@billing_period)
        rdg_2 = set_reading_2_to_reading(@subscriber,@meter,@billing_period)
        @reading.reading_1 = rdg_1
        @reading.reading_index_1 = rdg_1.try(:reading_index)
        @reading.reading_2 = rdg_2
        @reading.reading_index_2 = rdg_2.try(:reading_index)
        @reading.reading_sequence = @subscriber.reading_sequence
        @reading.reading_variant = @subscriber.reading_variant
        @reading.reading_route_id = @subscriber.reading_route_id
        @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading.created_by = current_user.id if !current_user.nil?

        if @reading.save
          respond_to do |format|
            if session[:return_to_subscriber].nil?
              format.html { redirect_to @reading, notice: t('activerecord.attributes.reading.successfully') }
            else
              format.html { redirect_to session[:return_to_subscriber_url], notice: t('activerecord.attributes.reading.successfully') }
            end
          end
        else
          respond_to do |format|
            if session[:return_to_subscriber].nil?
              format.html { redirect_to @reading, alert: t('activerecord.attributes.reading.repeat') }
            else
              format.html { redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.repeat') }
            end
          end
        end
      else
        respond_to do |format|
          if session[:return_to_subscriber].nil?
            format.html { redirect_to @reading, alert: t('activerecord.attributes.reading.repeat') }
          else
            format.html { redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.repeat') }
          end
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
      @subscriber = Subscriber.find(params[:reading][:subscriber_id])
      @meter = Meter.find(params[:reading][:meter_id])
      @project = Project.find(params[:reading][:project_id])
      @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
      @reading_exits = Reading.where( meter_id: params[:reading][:meter_id],
                                      project_id: params[:reading][:project_id],
                                      billing_period_id: params[:reading][:billing_period_id],
                                      reading_type_id: params[:reading][:reading_type_id]).
                              where("date(reading_date) = ?", params[:reading][:reading_date].split(' ')[0].to_date)

      @reading_exits -= [@reading]
      if @reading_exits.blank?

        incidences = params[:reading][:reading_incidences_ids]
        params[:reading].delete :reading_incidences_ids

        @reading.assign_attributes params[:reading]
        @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id incidences

        rdg_1 = set_reading_1_to_reading(@subscriber,@meter,@billing_period)
        rdg_2 = set_reading_2_to_reading(@subscriber,@meter,@billing_period)
        @reading.reading_1 = rdg_1
        @reading.reading_index_1 = rdg_1.try(:reading_index)
        @reading.reading_2 = rdg_2
        @reading.reading_index_2 = rdg_2.try(:reading_index)
        @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading.updated_by = current_user.id if !current_user.nil?
        if @reading.reading_index < @reading.reading_index_1
          @reading.reading_incidence_types << ReadingIncidenceType.find(1)
        end 

        respond_to do |format|
          if @reading.save
            if session[:return_to_subscriber].nil?
              format.html { redirect_to @reading,
                            notice: (crud_notice('updated', @reading) + "#{undo_link(@reading)}").html_safe }
            else
              format.html { redirect_to session[:return_to_subscriber_url], notice: (crud_notice('updated', @reading) + "#{undo_link(@reading)}").html_safe }
            end
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @reading.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          if session[:return_to_subscriber].nil?
            format.html { redirect_to @reading, alert: t('activerecord.attributes.reading.repeat') }
          else
            format.html { redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.repeat') }
          end
        end
      end
    end

    # DELETE /readings/1
    # DELETE /readings/1.json
    def destroy
      @reading = Reading.find(params[:id])

      respond_to do |format|
        if @reading.destroy
          if session[:return_to_subscriber].nil?
            format.html { redirect_to readings_url,
                        notice: (crud_notice('destroyed', @reading) + "#{undo_link(@reading)}").html_safe }
          else
            format.html { redirect_to session[:return_to_subscriber_url], notice: crud_notice('destroyed', @reading) }
          end
          format.json { head :no_content }
        else
          format.html { redirect_to readings_url, alert: "#{@reading.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

     # reading report
    def reading_report
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
        order_by :reading_date, :desc
        paginate :page => params[:page] || 1, :per_page => Reading.count
      end
      @reading_report = @search.results

      if !@reading_report.blank?
        title = t("activerecord.models.reading.few")
        @to = formatted_date(@reading_report.first.created_at)
        @from = formatted_date(@reading_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
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
        BillingPeriod.order("period DESC")
      else
        BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
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
