require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :r_reading_date,
                                                :r_find_meter,
                                                :r_find_subscriber,
                                                :reading_view_report
                                              ]

    def r_reading_date
      billing_period = BillingPeriod.find(params[:billing_period])
      reading_date = params[:reading_date]
      reading_date = (reading_date[0..3] + '-' + reading_date[4..5] + '-' + reading_date[6..7]).to_date
      code = ''

      if !billing_period.reading_starting_date.blank? && !billing_period.reading_ending_date.blank?
        if reading_date.between?(billing_period.reading_starting_date, billing_period.reading_ending_date)
          code = '$ok'
        elsif reading_date < (billing_period.reading_starting_date - 30)|| reading_date > (billing_period.reading_ending_date + 30)
          code = '$err'
        else
          code = '$err_ok'
        end
      end
      render json: { "code" => code }
    end

    #
    # Look for meter
    #
    def r_find_meter
      m = params[:meter]
      alert = ""
      code = ''
      meter_id = 0
      if m != '0'
        meter = Meter.find_by_meter_code(m) rescue nil
        if !meter.nil?
          s = Subscriber.find_by_meter_id(meter.id) rescue nil
          if s.nil?
            # Meter available
            alert = I18n.t("activerecord.errors.models.meter.available", var: m)
            meter_id = meter.id
          else
            # Meter installed and unavailable
            # Meter can be tested for been installed using meter.is_installed_now?
            alert = I18n.t("activerecord.errors.models.meter.installed", var: m)
            code = '$err'
          end
        else
          # Meter code not found
          alert = I18n.t("activerecord.errors.models.meter.code_not_found", var: m)
          code = '$err'
        end
      else
        # Wrong meter code
        alert = I18n.t("activerecord.errors.models.meter.code_wrong", var: m)
        code = '$err'
      end
      # Setup JSON
      @json_data = { "code" => code, "alert" => alert, "meter_id" => meter_id.to_s }
      render json: @json_data
    end

    #
    # Look for subscriber
    #
    def r_find_subscriber
      m = params[:subscriber]
      alert = ""
      code = ''
      subscribers = nil
      search_array = []

      if m != '$'
        search = Subscriber.search do
          fulltext m
          with :office_id, current_offices_ids
          with :ending_at, nil
          order_by :sort_no
        end
        subscribers = search.results

        if subscribers.empty?
          # No subscribers found
          alert = I18n.t("activerecord.errors.models.contracting_request.subscriber_not_found")
          code = '$err'
        else
          # Subscribers array
          search_array = subscribers_array(subscribers)
        end
      else
        # Invalid search string
        alert = I18n.t("activerecord.errors.models.contracting_request.invalid_search_string")
        code = '$err'
      end
      # Setup JSON
      @json_data = { "code" => code, "alert" => alert, "subscriber" => search_array }
      render json: @json_data
    end

    # GET /readings
    # GET /readings.json
    def index
      manage_filter_state
      subscriber = params[:Subscriber]
      meter = params[:Meter]
      # reading_date = params[:ReadingDate]
      period = params[:Period]
      route = params[:Route]
      from = params[:From]
      to = params[:To]
      incidences = params[:incidences]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      # @subscribers = subscribers_dropdown if @subscribers.nil?
      # @meters = meters_dropdown if @meters.nil?
      @periods = periods_dropdown if @periods.nil?
      @routes = routes_dropdown if @routes.nil?
      @reading_incidences = ReadingIncidenceType.all
      incidences.delete("") unless incidences.blank?

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
        if !incidences.blank?
          with :reading_incidence_type, incidences
        end
        order_by :by_period_date, :desc
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
      @projects = projects_dropdown
      @projects_ids = projects_dropdown_ids
      @billing_periods = BillingPeriod.order("period DESC").includes(:billing_frequency).find_all_by_project_id(@projects_ids)
      @subscribers = []

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading }
      end
    end

    # GET /readings/1/edit
    def edit
      @breadcrumb = 'update'
      @reading = Reading.find(params[:id])
      @projects = projects_dropdown
      @projects_ids = projects_dropdown_ids
      @billing_periods = BillingPeriod.order("period DESC").includes(:billing_frequency).find_all_by_project_id(@projects_ids)

      unless @reading.billable?
        url_return = session[:return_to_subscriber_url].blank? ? @reading : session[:return_to_subscriber_url]
        redirect_to url_return, alert: "No se puede modificar lecturas facturadas" and return
      end
    end

    # POST /readings
    # POST /readings.json
    def create
      @breadcrumb = 'create'
      @meter = Meter.find(params[:reading][:meter_id]) rescue nil
      if !@meter.blank?
        # All associations
        @subscriber = Subscriber.find(params[:reading][:subscriber_id]) rescue nil
        @service_point = ServicePoint.find(params[:reading][:service_point_id]) rescue nil
        @project = Project.find(params[:reading][:project_id])
        @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
        @reading_exits = Reading.where( meter_id: params[:reading][:meter_id],
                                        project_id: params[:reading][:project_id],
                                        billing_period_id: params[:reading][:billing_period_id],
                                        reading_type_id: params[:reading][:reading_type_id]) \
                                .where("date(reading_date) = ?", params[:reading][:reading_date].split(' ')[0].to_date)
        created_by = current_user.id if !current_user.nil?
        if @reading_exits.blank?
          if @meter.is_shared?
            @meter.subscribers.activated.each do |s|
              rdg_1 = set_reading_1_to_reading(s, @meter, @billing_period)
              rdg_2 = set_reading_2_to_reading(s, @meter, @billing_period)
              @reading = Reading.new(project_id: params[:reading][:project_id],
                                     billing_period_id: params[:reading][:billing_period_id],
                                     billing_frequency_id: @billing_period.try(:billing_frequency_id),
                                     reading_type_id: params[:reading][:reading_type_id],
                                     meter_id: params[:reading][:meter_id],
                                     subscriber_id: s.id,
                                     coefficient: s.meter.shared_coefficient,
                                     service_point_id: s.try(:service_point_id) || @service_point.try(:id),
                                     reading_route_id: s.try(:reading_route_id) || @service_point.try(:reading_route_id),
                                     reading_sequence: s.try(:reading_sequence) || @service_point.try(:reading_sequence),
                                     reading_variant: s.try(:reading_variant) || @service_point.try(:reading_variant),
                                     reading_date: params[:reading][:reading_date].to_date,
                                     reading_index: params[:reading][:reading_index],
                                     reading_1: rdg_1,
                                     reading_index_1: rdg_1.try(:reading_index),
                                     reading_2: rdg_2,
                                     reading_index_2: rdg_2.try(:reading_index),
                                     created_by: created_by)
              if !params[:incidence_type_ids].blank?
                @my_read_inci_type = ReadingIncidenceType.where(id: params[:incidence_type_ids])
                @reading.reading_incidence_types << @my_read_inci_type
              end
              if !@reading.save
                if session[:return_to_subscriber].nil?
                  redirect_to @reading, alert: t('activerecord.attributes.reading.wrongly')
                else
                  redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.wrongly')
                end
                break
              else
                # vuelta de contador
                if @reading.reading_index.to_i < @reading.reading_index_1.to_i
                  @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 1)
                end
                if !@reading.reading_1_id.blank? && Reading.find(@reading.reading_1_id).reading_type_id != ReadingType::INSTALACION
                  conbaj = (@reading.reading_1.consumption / 2)
                  conexc = (@reading.reading_1.consumption * 2)
                  # consumo excesivo
                  if @reading.consumption > conexc
                    @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 21)
                  end
                  # bajo consumo
                  if @reading.consumption < conbaj
                    @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 22)
                  end
                end
                # fuera de plazo
                if !@billing_period.reading_starting_date.blank? && !@billing_period.reading_ending_date.blank?
                  if !@reading.reading_date.between?(@billing_period.reading_starting_date, @billing_period.reading_ending_date)
                    @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 27)
                  end
                end
              end
            end # @meters.subscribers.activated do |s|
            if session[:return_to_subscriber].nil?
              redirect_to @reading, notice: t('activerecord.attributes.reading.create')
            else
              redirect_to session[:return_to_subscriber_url], notice: t('activerecord.attributes.reading.create')
            end
          else
            @reading = Reading.new(params[:reading])
            if !params[:incidence_type_ids].blank?
              @my_read_inci_type = ReadingIncidenceType.where(id: params[:incidence_type_ids])
              @reading.reading_incidence_types << @my_read_inci_type
            end
            rdg_1 = set_reading_1_to_reading(@subscriber, @meter, @billing_period)
            rdg_2 = set_reading_2_to_reading(@subscriber, @meter, @billing_period)
            @reading.service_point_id = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.service_point_id : @meter.service_points.first.id
            @reading.coefficient = @meter.shared_coefficient
            @reading.reading_1 = rdg_1
            @reading.reading_index_1 = rdg_1.try(:reading_index)
            @reading.reading_2 = rdg_2
            @reading.reading_index_2 = rdg_2.try(:reading_index)
            @reading.reading_sequence = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_sequence : @meter.service_points.first.reading_sequence
            @reading.reading_variant = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_variant : @meter.service_points.first.reading_variant
            @reading.reading_route_id = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_route_id : @meter.service_points.first.reading_route_id
            @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
            @reading.created_by = current_user.id if !current_user.nil?

            if @reading.save
              # vuelta de contador
              if @reading.reading_index.to_i < @reading.reading_index_1.to_i
                @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 1)
              end
              if !@reading.reading_1_id.blank? && Reading.find(@reading.reading_1_id).reading_type_id != ReadingType::INSTALACION
                conbaj = (@reading.reading_1.consumption / 2)
                conexc = (@reading.reading_1.consumption * 2)
                # consumo excesivo
                if @reading.consumption > conexc
                  @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 21)
                end
                # bajo consumo
                if @reading.consumption < conbaj
                  @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 22)
                end
              end
              # fuera de plazo
              if !@billing_period.reading_starting_date.blank? && !@billing_period.reading_ending_date.blank?
                if !@reading.reading_date.between?(@billing_period.reading_starting_date, @billing_period.reading_ending_date)
                  @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 27)
                end
              end
              if session[:return_to_subscriber].nil?
                redirect_to @reading, notice: t('activerecord.attributes.reading.create')
              else
                redirect_to session[:return_to_subscriber_url], notice: t('activerecord.attributes.reading.create')
              end
            else
              if session[:return_to_subscriber].nil?
                redirect_to @reading, alert: t('activerecord.attributes.reading.wrongly')
              else
                redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.wrongly')
              end
            end
          end # @meter.is_shared?
        else
          if session[:return_to_subscriber].nil?
            redirect_to @reading, alert: t('activerecord.attributes.reading.repeat')
          else
            redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.repeat')
          end
        end # @reading_exits.blank?
      end # !@meter.blank?
    end

    # PUT /readings/1
    # PUT /readings/1.json
    def update
      @breadcrumb = 'update'
      @reading = Reading.find(params[:id])
      @meter = @reading.meter
      if !@meter.blank?
        # All associations
        @subscriber = Subscriber.find(params[:reading][:subscriber_id]) rescue nil
        @service_point = ServicePoint.find(params[:reading][:service_point_id]) rescue nil
        @project = Project.find(params[:reading][:project_id])
        @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
        if !@meter.is_shared?
          @reading_exits = Reading.where( meter_id: params[:reading][:meter_id],
                                        project_id: params[:reading][:project_id],
                                        billing_period_id: params[:reading][:billing_period_id],
                                        reading_type_id: params[:reading][:reading_type_id]).
                                where("date(reading_date) = ?", params[:reading][:reading_date].split(' ')[0].to_date)

          @reading_exits -= [@reading]
        else
          @reading_exits = nil
        end
        if @reading_exits.blank?
          incidences = params[:reading][:reading_incidences_ids]
          params[:reading].delete :reading_incidences_ids
          if @meter.is_shared?
            @meter.subscribers.activated.each do |s|
              @reading = Reading.where( meter_id: params[:reading][:meter_id],
                                        project_id: params[:reading][:project_id],
                                        subscriber_id: s.id,
                                        billing_period_id: params[:reading][:billing_period_id],
                                        reading_type_id: params[:reading][:reading_type_id]).limit(1)

              rdg_1 = set_reading_1_to_reading(s, @meter, @billing_period)
              rdg_2 = set_reading_2_to_reading(s, @meter, @billing_period)
              @reading.first.update_attributes(project_id: params[:reading][:project_id],
                                         billing_period_id: params[:reading][:billing_period_id],
                                         billing_frequency_id: @billing_period.try(:billing_frequency_id),
                                         reading_type_id: params[:reading][:reading_type_id],
                                         meter_id: params[:reading][:meter_id],
                                         subscriber_id: s.id,
                                         service_point_id: s.try(:service_point_id) || @service_point.try(:id),
                                         reading_route_id: s.try(:reading_route_id) || @service_point.try(:reading_route_id),
                                         reading_sequence: s.try(:reading_sequence) || @service_point.try(:reading_sequence),
                                         reading_variant: s.try(:reading_variant) || @service_point.try(:reading_variant),
                                         reading_date: params[:reading][:reading_date].to_date,
                                         reading_index: params[:reading][:reading_index],
                                         reading_1: rdg_1,
                                         reading_index_1: rdg_1.try(:reading_index),
                                         reading_2: rdg_2,
                                         reading_index_2: rdg_2.try(:reading_index))
              @reading.first.reading_incidence_types = ReadingIncidenceType.find_all_by_id incidences
              jj = []
              if !@reading.first.reading_incidence_types.blank?
                @reading.first.reading_incidence_types.each do |a|
                  jj << a.id
                end
              end
              # vuelta de contador
              if @reading.first.reading_index < @reading.first.reading_index_1 and !jj.include?(1)
                @reading.first.reading_incidences.create(reading_id: @reading.first.id, reading_incidence_type_id: 1)
              end
              if !@reading.first.reading_1_id.blank? && Reading.find(@reading.first.reading_1_id).reading_type_id != ReadingType::INSTALACION
                conbaj = (@reading.first.reading_1.consumption / 2)
                conexc = (@reading.first.reading_1.consumption * 2)
                # consumo excesivo
                if @reading.first.consumption > conexc and !jj.include?(21)
                  @reading.first.reading_incidences.create(reading_id: @reading.first.id, reading_incidence_type_id: 21)
                end
                # bajo consumo
                if @reading.first.consumption < conbaj and !jj.include?(22)
                  @reading.first.reading_incidences.create(reading_id: @reading.first.id, reading_incidence_type_id: 22)
                end
              end
              # fuera de plazo
              if !@billing_period.reading_starting_date.blank? && !@billing_period.reading_ending_date.blank?
                if @reading.first.reading_date.between?(@billing_period.reading_starting_date, @billing_period.reading_ending_date) and !jj.include?(27)
                else
                  @reading.first.reading_incidences.create(reading_id: @reading.first.id, reading_incidence_type_id: 27)
                end
              end
              if !@reading.first.save
                if session[:return_to_subscriber].nil?
                  redirect_to @reading.first, alert: t('activerecord.attributes.reading.wrongly')
                else
                  redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.wrongly')
                end
                break
              end
            end # @meters.subscribers.activated do |s|
            if session[:return_to_subscriber].nil?
              redirect_to @reading, notice: t('activerecord.attributes.reading.create')
            else
              redirect_to session[:return_to_subscriber_url], notice: t('activerecord.attributes.reading.create')
            end
          else
            @reading.assign_attributes params[:reading]
            @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id incidences
            rdg_1 = set_reading_1_to_reading(@subscriber, @meter, @billing_period)
            rdg_2 = set_reading_2_to_reading(@subscriber, @meter, @billing_period)
            @reading.reading_1 = rdg_1
            @reading.reading_index_1 = rdg_1.try(:reading_index)
            @reading.reading_2 = rdg_2
            @reading.reading_index_2 = rdg_2.try(:reading_index)
            @reading.reading_sequence = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_sequence : @meter.service_points.first.reading_sequence
            @reading.reading_variant = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_variant : @meter.service_points.first.reading_variant
            @reading.reading_route_id = @subscriber.blank? && @meter.service_points.blank? ? nil : !@subscriber.blank? ? @subscriber.reading_route_id : @meter.service_points.first.reading_route_id
            @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
            @reading.created_by = current_user.id if !current_user.nil?
            jj = []
            if !@reading.reading_incidence_types.blank?
              @reading.reading_incidence_types.each do |a|
                jj << a.id
              end
            end
            # vuelta de contador
            if @reading.reading_index.to_i < @reading.reading_index_1.to_i and !jj.include?(1)
              @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 1)
            end
            if !@reading.reading_1_id.blank? && Reading.find(@reading.reading_1_id).reading_type_id != ReadingType::INSTALACION
              conbaj = (@reading.reading_1.consumption / 2)
              conexc = (@reading.reading_1.consumption * 2)
              # consumo excesivo
              if @reading.consumption > conexc and !jj.include?(21)
                @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 21)
              end
              # bajo consumo
              if @reading.consumption < conbaj and !jj.include?(22)
                @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 22)
              end
            end
            # fuera de plazo
            if !@billing_period.reading_starting_date.blank? && !@billing_period.reading_ending_date.blank?
              if @reading.reading_date.between?(@billing_period.reading_starting_date, @billing_period.reading_ending_date) and !jj.include?(27)
              else
                @reading.reading_incidences.create(reading_id: @reading.id, reading_incidence_type_id: 27)
              end
            end
            if @reading.save
              if session[:return_to_subscriber].nil?
                redirect_to @reading, notice: t('activerecord.attributes.reading.create')
              else
                redirect_to session[:return_to_subscriber_url], notice: t('activerecord.attributes.reading.create')
              end
            else
              if session[:return_to_subscriber].nil?
                redirect_to @reading, alert: t('activerecord.attributes.reading.wrongly')
              else
                redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.wrongly')
              end
            end
          end # @meter.is_shared?
        else
          if session[:return_to_subscriber].nil?
            redirect_to @reading, alert: t('activerecord.attributes.reading.repeat')
          else
            redirect_to session[:return_to_subscriber_url], alert: t('activerecord.attributes.reading.repeat')
          end
        end # @reading_exits.blank?
      end # !@meter.blank?
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
    def reading_view_report
      manage_filter_state
      subscriber = params[:Subscriber]
      meter = params[:Meter]
      period = params[:Period]
      route = params[:Route]
      from = params[:From]
      to = params[:To]
      incidences = params[:incidences]
      # OCO
      init_oco if !session[:organization]

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
        if !incidences.blank?
          with :reading_incidence_type, incidences
        end
        order_by :by_period_date, :desc
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
          format.csv { send_data Reading.to_csv(@reading_report),
                       filename: "#{title}_#{@from}-#{@to}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        end
      end
    end

    private

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).ser_or_tca_order_type
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).ser_or_tca_order_type
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).ser_or_tca_order_type : Project.ser_or_tca_order_type
      end
    end

    def projects_dropdown_ids
      projects_dropdown.pluck(:id)
    end

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
      # incidences
      if params[:incidences]
        session[:incidences] = params[:incidences]
      elsif session[:incidences]
        params[:incidences] = session[:incidences]
      end
    end

  end
end
