require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SubscribersController < ApplicationController
    #include ActionView::Helpers::NumberHelper
    helper_method :sort_column

    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :subscriber_pdf,
                                                :create,
                                                :add_meter,
                                                :quit_meter,
                                                :change_meter,
                                                :simple_bill,
                                                :void,
                                                :subscriber_report,
                                                :subscriber_tec_report,
                                                :subscriber_eco_report,
                                                :rebilling ]

    def update_simple
      @subscriber = Subscriber.find params[:id]
      params[:invoice_item].each do |obj_inv|
        pre_invoice_item = PreInvoiceItem.find(obj_inv[0])
        pre_invoice_item.update_attributes(obj_inv[1])
      end
      redirect_to subscriber_path(@subscriber), notice: "PreFactura actualizada correctamente"
    end

    def void
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      void_bill(@bill)
      redirect_to subscriber_path(@subscriber), notice: "Factura anulada"
    end

    def rebilling
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      @period = @bill.reading_2.billing_period_id
      void_bill(@bill)
      @reading = @subscriber.readings.find_by_billing_period_id_and_reading_type_id(@period, ReadingType::NORMAL)
      @pre_bill = @reading.generate_pre_bill
      respond_to do |format|
        format.js { render "simple_bill" }
      end
    end

    def add_meter

      @subscriber = Subscriber.find(params[:id])
      @subscriber.meter_id = params[:reading][:meter_id]

      ######ReadingIncidenceTypes##########
      @reading_incidence_types = params[:incidence_type_ids]

      #Update JavaScript
      if !@reading_incidence_types.blank? #True
        @reading_incidence_types = ReadingIncidenceType.where(id: @reading_incidence_types).map(&:name)
      else #False
        @reading_incidence_types = []
      end

      #Get last Reading
      last_reading = @subscriber.readings.order(:reading_date).last

      #Update caliber WaterSupplyContract
      water_supply_contract = @subscriber.contracting_request.water_supply_contract #WaterSupplyContract.where(subscriber_id: @subscriber.id)
      water_supply_contract.caliber_id = Meter.find(params[:reading][:meter_id]).caliber_id

      #Create MeterDetail
      @meter_detail = MeterDetail.new( meter_id: params[:reading][:meter_id],
                                       subscriber_id: params[:id],
                                       installation_date:  params[:reading][:reading_date],
                                       installation_reading: params[:reading][:reading_index],
                                       withdrawal_date: nil,
                                       withdrawal_reading: nil )

      #Create Reading
      @reading = Reading.new( project_id: last_reading.project_id,
                   billing_period_id: nil,
                   billing_frequency_id: last_reading.billing_frequency_id,
                   reading_type_id: ReadingType.find(4).id, #ReadingType Installation
                   meter_id: params[:reading][:meter_id],
                   subscriber_id: @subscriber.id,
                   reading_route_id: last_reading.reading_route_id,
                   reading_date: params[:reading][:reading_date],
                   reading_index: params[:reading][:reading_index],
                   reading_sequence: last_reading.reading_sequence,
                   reading_variant: nil,
                   reading_index_1: nil,
                   reading_index_2: nil )

      #Add ReadingIncidenceTypes to Reading
      if params[:incidence_type_ids].blank? #[]
      else
        @my_read_inci_type = ReadingIncidenceType.find(params[:incidence_type_ids])
        @reading.reading_incidence_types << @my_read_inci_type
      end

      #Save all
      water_supply_contract.save
      @meter_detail.save
      @reading.save
      @subscriber.save

      response_hash = { subscriber: @subscriber }
      response_hash[:reading] = @reading
      response_hash[:reading_type_name] = @reading.reading_type.name
      response_hash[:reading_incidence_types] = @reading_incidence_types
      response_hash[:meter] = @subscriber.meter
      response_hash[:meter_model] = @subscriber.meter.meter_model
      response_hash[:caliber] = @subscriber.meter.caliber

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: response_hash }
        format.js
      end
    end


    def quit_meter

      ######ReadingIncidenceTypes##########
      @reading_incidence_types = params[:incidence_type_ids]

      #Update JavaScript
      if !@reading_incidence_types.blank? #True
        @reading_incidence_types = ReadingIncidenceType.where(id: @reading_incidence_types).map(&:name)
      else #False
        @reading_incidence_types = []
      end

      @subscriber = Subscriber.find(params[:id])

      #Get last Reading
      last_reading = @subscriber.readings.order(:reading_date).last

      #Update MeterDetail associated
      @meter_details = MeterDetail.where(meter_id: @subscriber.meter_id)
      @meter_detail = @meter_details.where(withdrawal_date: nil).first
      @meter_detail.withdrawal_date = params[:reading][:reading_date]
      @meter_detail.withdrawal_reading = params[:reading][:reading_index]

      #Create Reading
      @reading = Reading.new( project_id: last_reading.project_id,
                   billing_period_id: nil,
                   billing_frequency_id: last_reading.billing_frequency_id,
                   reading_type_id: ReadingType.find(5).id, #ReadingType Withdrawal
                   meter_id: @subscriber.meter_id,
                   subscriber_id: @subscriber.id,
                   reading_route_id: last_reading.reading_route_id,
                   reading_date: params[:reading][:reading_date],
                   reading_index: params[:reading][:reading_index],
                   reading_sequence: last_reading.reading_sequence,
                   reading_variant: nil,
                   reading_index_1: nil,
                   reading_index_2: nil )

      #Put Caliber Nil
      water_supply_contract = @subscriber.water_supply_contract #WaterSupplyContract.where(subscriber_id: @subscriber.id)
      water_supply_contract.caliber_id = nil

      #Subscriber Quit Meter associated
      @subscriber.meter_id = nil

      #Add ReadingIncidenceTypes to Reading
      if params[:incidence_type_ids].blank? #[]
      else
        @my_read_inci_type = ReadingIncidenceType.find(params[:incidence_type_ids])
        @reading.reading_incidence_types << @my_read_inci_type
      end

      #Save all
      @meter_detail.save
      water_supply_contract.save
      @reading.save
      @subscriber.save

      #BillingPeriod ¿?
      #Return reading_type.name

      response_hash = { subscriber: @subscriber }
      response_hash[:reading] = @reading
      response_hash[:reading_type_name] = @reading.reading_type.name
      response_hash[:reading_incidence_types] = @reading_incidence_types

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: response_hash }
        format.js
      end
    end

    def change_meter

      @subscriber = Subscriber.find(params[:id])

      ############### QUIT METER ########################

      #ReadingIncidenTypes
      @reading_incidence_types_quit = params[:incidence_type_ids_quit]

      #Update JavaScript
      if !@reading_incidence_types_quit.blank? #True
        @reading_incidence_types_quit = ReadingIncidenceType.where(id: @reading_incidence_types_quit).map(&:name)
      else #False
        @reading_incidence_types_quit = []
      end

      #Get last Reading
      last_reading = @subscriber.readings.order(:reading_date).last

      #Update MeterDetail associated
      @meter_details = MeterDetail.where(meter_id: @subscriber.meter_id)
      @meter_detail = @meter_details.where(withdrawal_date: nil).first
      @meter_detail.withdrawal_date = params[:reading][:reading_date]
      @meter_detail.withdrawal_reading = params[:reading][:reading_index]

      #Create Reading
      @reading_quit = Reading.new( project_id: last_reading.project_id,
                   billing_period_id: nil,
                   billing_frequency_id: last_reading.billing_frequency_id,
                   reading_type_id: ReadingType.find(5).id, #ReadingType Withdrawal
                   meter_id: @subscriber.meter_id,
                   subscriber_id: @subscriber.id,
                   reading_route_id: last_reading.reading_route_id,
                   reading_date: params[:reading][:reading_date],
                   reading_index: params[:reading][:reading_index],
                   reading_sequence: last_reading.reading_sequence,
                   reading_variant: nil,
                   reading_index_1: nil,
                   reading_index_2: nil )

      #Add ReadingIncidenceTypes to Reading
      if params[:incidence_type_ids_quit].blank? #[]
      else
        @my_read_inci_type = ReadingIncidenceType.find(params[:incidence_type_ids_quit])
        @reading_quit.reading_incidence_types << @my_read_inci_type
      end

      #Put Caliber Nil
      water_supply_contract = @subscriber.contracting_request.water_supply_contract #WaterSupplyContract.where(subscriber_id: @subscriber.id)
      water_supply_contract.caliber_id = nil

      #Subscriber Quit Meter associated
      @subscriber.meter_id = nil

      #Save all
      @meter_detail.save
      water_supply_contract.save
      @reading_quit.save
      @subscriber.save

      ################# ADD METER ###############################333

      #ReadingIncidenTypes
      @reading_incidence_types_add = params[:incidence_type_ids_add]

      #Update JavaScript
      if !@reading_incidence_types_add.blank? #True
        @reading_incidence_types_add = ReadingIncidenceType.where(id: @reading_incidence_types_add).map(&:name)
      else #False
        @reading_incidence_types_add = []
      end

      @subscriber.meter_id = params[:reading][:meter_id]

      #Get last Reading
      last_reading = @subscriber.readings.order(:reading_date).last

      #Update caliber WaterSupplyContract
      water_supply_contract = @subscriber.contracting_request.water_supply_contract #WaterSupplyContract.where(subscriber_id: @subscriber.id)
      water_supply_contract.caliber_id = Meter.find(params[:reading][:meter_id]).caliber_id

      #Create MeterDetail
      @meter_detail = MeterDetail.new( meter_id: params[:reading][:meter_id],
                                       subscriber_id: params[:id],
                                       installation_date:  params[:reading][:reading_date_add],
                                       installation_reading: params[:reading][:reading_index_add],
                                       withdrawal_date: nil,
                                       withdrawal_reading: nil )

      #Create Reading
      @reading = Reading.new( project_id: last_reading.project_id,
                   billing_period_id: nil,
                   billing_frequency_id: last_reading.billing_frequency_id,
                   reading_type_id: ReadingType.find(4).id, #ReadingType Installation
                   meter_id: params[:reading][:meter_id],
                   subscriber_id: @subscriber.id,
                   reading_route_id: last_reading.reading_route_id,
                   reading_date: params[:reading][:reading_date_add],
                   reading_index: params[:reading][:reading_index_add],
                   reading_sequence: last_reading.reading_sequence,
                   reading_variant: nil,
                   reading_index_1: nil,
                   reading_index_2: nil )

      #Add ReadingIncidenceTypes to Reading
      if params[:incidence_type_ids_add].blank? #[]
      else
        @my_read_inci_types = ReadingIncidenceType.find(params[:incidence_type_ids_add])
        @reading.reading_incidence_types << @my_read_inci_types
      end

      #Save all
      water_supply_contract.save
      @meter_detail.save
      @reading.save
      @subscriber.save

      response_hash = { subscriber: @subscriber }
      response_hash[:reading] = @reading
      response_hash[:reading_quit] = @reading_quit
      response_hash[:reading_type_quit] = @reading_quit.reading_type.name
      response_hash[:reading_type_add] = @reading.reading_type.name

      response_hash[:reading_incidence_types_quit] = @reading_incidence_types_quit
      response_hash[:reading_incidence_types_add] = @reading_incidence_types_add

      response_hash[:meter] = @subscriber.meter
      response_hash[:meter_model] = @subscriber.meter.meter_model
      response_hash[:caliber] = @subscriber.meter.caliber

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: response_hash }
        format.js
      end

    end

    # GET /subscribers
    # GET /subscribers.json
    def index
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @service_points = service_points_dropdown if @service_points.nil?
      @meters = meters_dropdown if @meters.nil?

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @subscribers = @search.results
      @reports = reports_array

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subscribers }
        format.js
      end
    end


    def subscriber_pdf

      @subscriber = Subscriber.find(params[:id])
      @billing_periods = BillingPeriod.all
      #@from = params[:from]
      #@to = params[:to]

      #from = Time.parse(@from).strftime("%Y-%m-%d")
      #to = Time.parse(@to).strftime("%Y-%m-%d")

      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill

      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "SCR-#{@subscriber.id}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    # GET /subscribers/1
    # GET /subscribers/1.json
    def show
      manage_filter_state_show
      filter = params[:ifilter]

      @breadcrumb = 'read'
      @subscriber = Subscriber.find(params[:id])
      @reading = Reading.new
      @client_bank_account = ClientBankAccount.new

      #@subscriberreadings = Reading.where(:subscriber_id => @subscriber.id).paginate(:page => 10, :per_page => per_page)
      # @reading_types = ReadingType.all
      # @client_bank_account = ClientBankAccount.where(client_id: @subscriber.client_id).active.first
      #Select Option BillingPeriod Associated
      # billing_periods_ids = @subscriber.readings.map(&:billing_period_id).uniq #Ids BillingPeriods associated
      # @billing_periods = BillingPeriod.where(id: billing_periods_ids) #BillingPeriods associated
      #
      # #Select Option ReadingTypes Associated
      # reading_types_ids = @subscriber.readings.map(&:reading_type_id).uniq
      # @reading_types = ReadingType.where(id: reading_types_ids) #ReadingTypes associated

      # @project_dropdown = session[:company].blank? ? Project.all : Project.where(company_id: session[:company])

      # @subscriber_readings = @subscriber.readings.paginate(:page => params[:page], :per_page => 5)
      @subscriber_accounts = @subscriber.client.client_bank_accounts.paginate(:page => params[:page], :per_page => 10)
      # @subscriber_bills = @subscriber.bills.order("created_at DESC").paginate(:page => params[:page], :per_page => 5)

      #@alliance_towns = @alliance.players.towns.order("rank ASC").paginate(:page => params[:page], :per_page => 1)
      #@bills = Bill.joins(:subscriber).paginate(:page => params[:page], :per_page => 1) #.where('subscriber.bill = ?', params[:id]).paginate(:page => params[:page], :per_page => 1)
      #@subscribers = Subscriber.joins(:bill).where('bills.subscriber_id = ?', params[:id]).paginate(:page => params[:page], :per_page => 1)
      #@subscribers = Bill.joins(:subscriber).paginate(:page => params[:page], :per_page => 5)

      @search_bills = Bill.search do
        if filter == "pending" or filter == "unpaid"
          with(:invoice_status_id, 0..98)
        elsif filter == "charged"
          with :invoice_status_id, 99
        end
        with :subscriber_id, params[:id]
        order_by :created_at, :asc
        paginate :page => params[:page] || 1, :per_page => 5
      end

      @search_readings = Reading.search do
        with :subscriber_id, params[:id]
        order_by :created_at, :asc
        paginate :page => params[:page] || 1, :per_page => 5
      end

      @subscriber_readings = @search_readings.results
      @subscriber_bills = @search_bills.results

      respond_to do |format|
       format.html # show.html.erb
       format.json { render json: @subscriber_bills }
       format.js
      end
    end

    def show_test
      @breadcrumb = 'read'
    end

    # GET /subscribers/new
    # GET /subscribers/new.json
    def new
      @breadcrumb = 'create'
      @subscriber = Subscriber.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber }
      end
    end

    # GET /subscribers/1/edit
    def edit
      @subscriber = Subscriber.find(params[:id])
    end

    # POST /subscribers
    # POST /subscribers.json
    def create
      @contracting_request = ContractingRequest.find params[:contracting_request_id]
      params_meter_details = params[:subscriber][:meter_details_attributes]["0"]
      params_readings = params[:subscriber][:readings_attributes]["0"]
      params[:subscriber].delete :meter_details_attributes
      params[:subscriber].delete :readings_attributes
      @subscriber = Subscriber.new(params[:subscriber])
      @subscriber.assign_attributes(
        active: true,
        billing_frequency_id: @contracting_request.water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id),
        building: @contracting_request.subscriber_building,
        cadastral_reference: @contracting_request.water_supply_contract.try(:cadastral_reference),
        cellular: @contracting_request.entity.cellular,
        center_id: @contracting_request.subscriber_center_id,
        client_id: @contracting_request.water_supply_contract.client_id,
        # contract: ,
        # country_id: @contracting_request.subscriber_country_id,
        email: @contracting_request.entity.email,
        # ending_at: ,
        endowments: @contracting_request.water_supply_contract.try(:endowments),
        fax: @contracting_request.entity.fax,
        fiscal_id: @contracting_request.entity.fiscal_id,
        floor: @contracting_request.subscriber_floor,
        floor_office: @contracting_request.subscriber_floor_office,
        gis_id: @contracting_request.water_supply_contract.try(:gis_id),
        inhabitants: @contracting_request.water_supply_contract.try(:inhabitants),
        # name: @contracting_request.entity.try(:full_name),
        office_id: @contracting_request.project.try(:office).try(:id),
        phone: @contracting_request.entity.phone,
        # province_id: @contracting_request.subscriber_province_id,
        # region_id: @contracting_request.subscriber_region_id,
        remarks: @contracting_request.try(:water_supply_contract).try(:remarks),
        starting_at: Time.now,
        street_directory_id: @contracting_request.subscriber_street_directory_id,
        # street_name: @contracting_request.subscriber_street_name,
        street_number: @contracting_request.subscriber_street_number,
        # street_type_id: @contracting_request.subscriber_street_type_id,
        subscriber_code: sub_next_no(@contracting_request.project.office_id),
        # town_id: @contracting_request.subscriber_town_id,
        zipcode_id: @contracting_request.subscriber_zipcode_id,
        tariff_scheme_id: @contracting_request.water_supply_contract.tariff_scheme_id,
        first_name: @contracting_request.entity.first_name,
        last_name: @contracting_request.entity.last_name,
        company: @contracting_request.entity.company,
        service_point_id: @contracting_request.service_point_id
      )
      if @subscriber.save
        billing_frequency = @contracting_request.water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id)
        @reading = @subscriber.readings.build(
          project_id: @contracting_request.project_id,
          billing_period_id: params_readings[:billing_period_id],
          billing_frequency_id: billing_frequency,
          reading_type_id: 4, #installation
          meter_id: @subscriber.meter_id,
          reading_route_id: @subscriber.reading_route_id,
          reading_sequence: @subscriber.reading_sequence,
          reading_variant:  @subscriber.reading_variant,
          reading_date: params_meter_details[:installation_date],
          reading_index: params_meter_details[:installation_reading]
        )
        # SUBROGATION
        if @contracting_request.old_subscriber
          @contracting_request.old_subscriber.update_attributes(ending_at: Date.today, meter_id: nil)
          # update meter details withdrawal
          @contracting_request.old_subscriber.meter_details.last.update_attributes(withdrawal_date: Date.today ,
                                                              withdrawal_reading: @contracting_request.old_subscriber.readings.last.reading_index)
        end
        @meter_details = @subscriber.meter_details.build(params_meter_details)
        @meter_details.assign_attributes(meter_id: @subscriber.meter_id)
        @contracting_request.water_supply_contract.update_attributes(meter_id: @subscriber.meter_id)
        if @subscriber.save
          @contracting_request.status_control
          if @contracting_request.save
            @contracting_request.water_supply_contract.update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract
            @contracting_request.water_supply_contract.bill.update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
            response_hash = { subscriber: @subscriber }
            response_hash[:reading] = @reading
            respond_to do |format|
              format.json { render json: response_hash }
            end
          else
            respond_to do |format|
              format.json { render :json => { :errors => @subscriber.errors.as_json }, :status => 420 }
            end
          end
        else
          respond_to do |format|
            format.json { render :json => { :errors => @contracting_request.errors.as_json }, :status => 420 }
          end
        end
      else
        respond_to do |format|
          format.json { render :json => { :errors => @subscriber.errors.as_json }, :status => 420 }
        end
      end
    end

    # PUT /subscribers/1
    # PUT /subscribers/1.json
    def update
      @subscriber = Subscriber.find(params[:id])

      respond_to do |format|
        if @subscriber.update_attributes(params[:subscriber])
          format.html { redirect_to @subscriber, notice: t( 'activerecord.attributes.subscriber.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /subscribers/1
    # DELETE /subscribers/1.json
    def destroy
      @subscriber = Subscriber.find(params[:id])
      @subscriber.destroy

      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end

    def popover
      @reading_incidence = ReadingIncidence.find(params[:id])
      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end

    def simple_bill
      @subscriber = Subscriber.find params[:id]
      @reading = @subscriber.readings.find_by_billing_period_id_and_reading_type_id(params[:bills][:billing_period_id], ReadingType::NORMAL)
      @pre_bill = @reading.generate_pre_bill
      respond_to do |format|
        format.js { }
      end
    end

    # subscriber report
    def subscriber_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_report = @search.results

      if !@subscriber_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_report.first.created_at)
        @from = formatted_date(@subscriber_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end


     # subscriber tec report
    def subscriber_tec_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_tec_report = @search.results

      if !@subscriber_tec_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_tec_report.first.created_at)
        @from = formatted_date(@subscriber_tec_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

     # subscriber eco report
    def subscriber_eco_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_eco_report = @search.results

      if !@subscriber_eco_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_eco_report.first.created_at)
        @from = formatted_date(@subscriber_eco_report.last.created_at)
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

    def reports_array()
      _array = []
      _array = _array << t("ag2_gest.subscribers.report.subscriber_report")
      _array = _array << t("ag2_gest.subscribers.report.subscriber_tec_report")
      _array = _array << t("ag2_gest.subscribers.report.subscriber_eco_report")
      _array
    end

    def void_bill(bill)
      bill_cancel = bill.dup
      bill_cancel.bill_no = bill_next_no(bill.project_id)
      if bill_cancel.save
        bill.invoices.each do |invoice|
          new_invoice = invoice.dup
          new_invoice.invoice_no = invoice_next_no(bill.project.company_id)
          new_invoice.bill_id = bill_cancel.id
          new_invoice.save
          # invoice_cancel = Invoice.create(
          #   bill_id: bill_cancel.id,
          #   invoice_no: invoice.invoice_no,
          #   invoice_date: Date.today,
          #   invoice_status_id: invoice.invoice_status_id,
          #   invoice_type_id: invoice.invoice_type_id,
          #   tariff_scheme_id: invoice.tariff_scheme_id,
          #   biller_id: invoice.biller_id
          # )
          invoice.invoice_items.each do |item|
            new_item = item.dup
            new_item.invoice_id = new_invoice.id
            new_item.price = new_item.price * -1
            # InvoiceItem.create(
            #   invoice_id: invoice_cancel.id,
            #   code: item.code,
            #   description: item.description,
            #   quantity: item.quantity,
            #   price: item.price * -1,
            #   tax_type_id: item.tax_type_id,
            #   discount_pct: item.discount_pct,
            #   tariff_id: item.tariff_id)
            new_item.save
          end
        end
      else
        return false
      end
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Subscriber.where('subscriber_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.subscriber_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def service_points_dropdown
      if session[:office] != '0'
        ServicePoint.where(office_id: session[:office]).order(:street_directory_id)
      elsif session[:company] != '0'
        ServicePoint.where(company_id: session[:company]).order(:street_directory_id)
      elsif session[:organization] != '0'
        ServicePoint.where(organization_id: session[:organization]).order(:street_directory_id)
      else
        ServicePoint.order(:street_directory_id)
      end
    end

    def meters_dropdown
      if session[:office] != '0'
        Meter.where(office_id: session[:office]).order(:meter_code)
      elsif session[:company] != '0'
        Meter.where(company_id: session[:company]).order(:meter_code)
      else
        Meter.order(:meter_code)
      end
    end

    def manage_filter_state_show
      if params[:ifilter]
        session[:ifilter] = params[:ifilter]
      elsif session[:ifilter]
        params[:ifilter] = session[:ifilter]
      end
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # subscriber_code
      if params[:SubscriberCode]
        session[:SubscriberCode] = params[:SubscriberCode]
      elsif session[:SubscriberCode]
        params[:SubscriberCode] = session[:SubscriberCode]
      end
      # service_point
      if params[:ServicePoint]
        session[:ServicePoint] = params[:ServicePoint]
      elsif session[:ServicePoint]
        params[:ServicePoint] = session[:ServicePoint]
      end
      # meter
      if params[:Meter]
        session[:Meter] = params[:Meter]
      elsif session[:Meter]
        params[:Meter] = session[:Meter]
      end
      # billing_frequency
      if params[:BillingFrequency]
        session[:BillingFrequency] = params[:BillingFrequency]
      elsif session[:BillingFrequency]
        params[:BillingFrequency] = session[:BillingFrequency]
      end
      # manufacturer
      if params[:Manufacturer]
        session[:Manufacturer] = params[:Manufacturer]
      elsif session[:Manufacturer]
        params[:Manufacturer] = session[:Manufacturer]
      end
      # tax
      if params[:TariffType]
        session[:TariffType] = params[:TariffType]
      elsif session[:TariffType]
        params[:TariffType] = session[:TariffType]
      end
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end

  end
end
