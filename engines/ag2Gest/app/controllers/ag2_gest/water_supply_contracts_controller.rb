require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterSupplyContractsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource


    # GET /water_supply_contracts
    # GET /water_supply_contracts.json
    def index
      manage_filter_state
      no = params[:No]
      subscriber = params[:Subscriber]
      meter = params[:Meter]
      order = params[:Order]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      # @subscribers = subscribers_dropdown if @subscribers.nil?
      # @meters = meters_dropdown if @meters.nil?
      @tariff_schemes = tariff_schemes_dropdown if @tariff_schemes.nil?
      @calibers = calibers_dropdown if @calibers.nil?

      # ContractingRequest for current projects
      current_contracting_request = ContractingRequest.where(project_id: current_projects_ids).map(&:id)

      @search = WaterSupplyContract.search do
        if !current_contracting_request.blank?
          with :contracting_request_id, current_contracting_request
        end
        fulltext params[:search]
        if !no.blank?
          with(:request_no).starting_with(no)
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        if !meter.blank?
          fulltext meter
        end
        if !order.blank?
          with :tariff_scheme_id, order
        end
        if !caliber.blank?
          with :caliber_id, caliber
        end
        if !from.blank?
          any_of do
            with(:invoice_date).greater_than(from)
            with :invoice_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:invoice_date).less_than(to)
            with :invoice_date, to
          end
        end
        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @water_supply_contracts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_supply_contracts }
        format.js
      end
    end

    # GET /water_supply_contracts/1
    # GET /water_supply_contracts/1.json
    def show
      @breadcrumb = 'read'
      @water_supply_contract = WaterSupplyContract.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_supply_contract }
      end
    end

    # GET /water_supply_contracts/new
    # GET /water_supply_contracts/new.json
    # def new
    #   @breadcrumb = 'create'
    #   @water_supply_contract = WaterSupplyContract.new

    #   respond_to do |format|
    #     format.html # new.html.erb
    #     format.json { render json: @water_supply_contract }
    #   end
    # end

    # GET /water_supply_contracts/1/edit
    # def edit
    #   @breadcrumb = 'update'
    #   @water_supply_contract = WaterSupplyContract.find(params[:id])
    # end

    # POST /water_supply_contracts
    # POST /water_supply_contracts.json
    def create
      @breadcrumb = 'create'
      @contracting_request = ContractingRequest.find(params[:water_supply_contract][:contracting_request_id])
      @tariff_scheme = TariffScheme.find(params[:water_supply_contract][:tariff_scheme_id])
      _tariff_type_ids = params[:TariffType_]
      _billable_items = params[:BillableConcept_]
      #@meter = Meter.find params[:water_supply_contract][:meter_id]
      @meter = Meter.where(id: params[:water_supply_contract][:meter_id]).first
      @meter_model = @meter.try(:meter_model)
      @meter_brand = @meter_model.meter_brand unless @meter_model.blank?
      @caliber = @meter.blank? ? Caliber.find(params[:water_supply_contract][:caliber_id]) : @meter.try(:caliber)

      # @billable_item = BillableItem.find_by_project_id_and_billable_concept_id(@contracting_request.project_id, 3) # 3 for contrataction
      # @tariff = Tariff.find_by_tariff_scheme_id_and_caliber_id_and_billable_item_id(@tariff_scheme.id, @caliber.id, @billable_item.id)
      @water_supply_contract = WaterSupplyContract.new(params[:water_supply_contract].except(:meter_code_input))
      # @water_supply_contract.tariff_id = @tariff.try(:id)
      _project = @contracting_request.project_id
      _type = @contracting_request.contracting_request_type_id
      @water_supply_contract.contract_no = contract_next_no(_project,_type) if _type == ContractingRequestType::SUPPLY || _type == ContractingRequestType::CHANGE_OWNERSHIP
      @water_supply_contract.contract_date = @contracting_request.request_date.strftime("%Y-%m-%d")
      @water_supply_contract.created_by = current_user.id if !current_user.nil?
      if @water_supply_contract.save
      if !@contracting_request.work_order.blank?
        if !@contracting_request.work_order.caliber.blank?
          @caliber = @contracting_request.work_order.caliber
          @water_supply_contract.update_attributes(caliber_id: @caliber.id)
        end
      end
        _tariff_type_ids.each do |r|
          _tariff_type = TariffType.find(r)
          _billable_items.each do |b|
            tariffs = Tariff.availables_to_project_type_document_caliber(b,@contracting_request.project_id,_tariff_type.id,1,@caliber.id)
            tariffs.each do |a|
              if !@water_supply_contract.tariffs.include?(a)
                @water_supply_contract.tariffs << a
              end
            end
          end
        end

        # @meters_availables_subscriber = Meter.from_office(session[:office]).availables(@contracting_request.try(:old_subscriber).try(:meter_id)).select{|m| m.caliber_id == @water_supply_contract.caliber_id}
        # data_meters = Array.new
        # @meters_availables_subscriber.each{|m| data_meters << {id: m.id, text: m.to_label}}
        response_hash = { water_supply_contract: @water_supply_contract }
        response_hash[:tariff_scheme] = @tariff_scheme
        response_hash[:caliber] = @caliber.caliber
        response_hash[:meter] = @meter
        # response_hash[:meters_subscriber] = data_meters
        response_hash[:meter_model] = @meter_model
        response_hash[:meter_brand] = @meter_brand.try(:brand)
        response_hash[:tariff_type] = @tariff_scheme.tariff_type
        # response_hash[:tariff] = @tariff.fixed_fee.to_s if @tariff
        # response_hash[:billing_frequency] = @tariff.billing_frequency.name if @tariff
        respond_to do |format|
          format.html { redirect_to @water_supply_contract.contracting_request, notice: crud_notice( t('activerecord.attributes.water_supply_contract.created'), @water_supply_contract) }
          format.json { render json: response_hash, status: :created, location: @water_supply_contract.contracting_request }
        end
      else
        respond_to do |format|
          format.html { redirect_to @water_supply_contract.contracting_request, notice: crud_notice( t('activerecord.attributes.water_supply_contract.created'), @water_supply_contract) }
          format.json { render json: @water_supply_contract.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /water_supply_contracts/1
    # PUT /water_supply_contracts/1.json
    def update
      @breadcrumb = 'update'
      @water_supply_contract = WaterSupplyContract.find(params[:id])
      @contracting_request = ContractingRequest.find(params[:water_supply_contract][:contracting_request_id])
      @tariff_scheme = TariffScheme.find(params[:water_supply_contract][:tariff_scheme_id])
      _tariff_type_ids = params[:TariffType_]
      _billable_items = params[:BillableConcept_]
      @meter = Meter.where(id: params[:water_supply_contract][:meter_id]).first
      @meter_model = @meter.try(:meter_model)
      @meter_brand = @meter_model.meter_brand unless @meter_model.blank?
      @caliber = @meter.try(:caliber) || Caliber.find(params[:water_supply_contract][:caliber_id])

      # @billable_item = BillableItem.find_by_project_id_and_billable_concept_id(@contracting_request.project_id, 3) # 3 for contrataction
      # @tariff = Tariff.find_by_tariff_scheme_id_and_caliber_id_and_billable_item_id(@tariff_scheme.id, @caliber.id, @billable_item.id)
      # @meters_availables_subscriber = Meter.from_office(session[:office]).availables(@contracting_request.try(:old_subscriber).try(:meter_id)).select{|m| m.caliber_id == @water_supply_contract.caliber_id}
      # data_meters = Array.new
      # @meters_availables_subscriber.each{|m| data_meters << {id: m.id, text: m.to_label}}
      # @water_supply_contract.tariff_id = @tariff.try(:id)
      @water_supply_contract.updated_by = current_user.id if !current_user.nil?
      if @water_supply_contract.update_attributes(params[:water_supply_contract].except(:meter_code_input))
        if !@contracting_request.work_order.blank?
          if !@contracting_request.work_order.caliber.blank?
            @caliber = @contracting_request.work_order.caliber
            @water_supply_contract.update_attributes(caliber_id: @caliber.id)
          end
        end
        if @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION or @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
          @billing_period = BillingPeriod.find(params[:BillingPeriodForReading])
          @subscriber_r = @contracting_request.old_subscriber
          @meter_r = @contracting_request.old_subscriber.meter
          rdg_1 = set_reading_1_to_reading(@subscriber_r,@meter_r,@billing_period)
          rdg_2 = set_reading_2_to_reading(@subscriber_r,@meter_r,@billing_period)
          if @contracting_request.old_subscriber.readings.last.reading_type_id != ReadingType::RETIRADA
            # pervious_period_id = BillingPeriod.find_by_period_and_billing_frequency_id(@billing_period.previous_period,@billing_period.billing_frequency_id).try(:id)
            # pervious_year_id = BillingPeriod.find_by_period_and_billing_frequency_id(@billing_period.year_period,@billing_period.billing_frequency_id).try(:id)
            # rdg_1 = Reading.where(subscriber_id: @contracting_request.old_subscriber, reading_type_id: [ReadingType::INSTALACION,ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO], billing_period_id: pervious_period_id).first
            # rdg_2 = Reading.where(subscriber_id: @contracting_request.old_subscriber, reading_type_id: [ReadingType::INSTALACION,ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO], billing_period_id: pervious_year_id).first
            #lectura de retirada
              @reading = Reading.create(
                subscriber_id: @contracting_request.old_subscriber.id,
                service_point_id: @contracting_request.old_subscriber.service_point_id,
                coefficient: @contracting_request.old_subscriber.meter.shared_coefficient,
                project_id: @contracting_request.project_id,
                billing_period_id: @billing_period.id,
                billing_frequency_id: BillingPeriod.find(params[:BillingPeriodForReading]).billing_frequency_id,
                reading_type_id: ReadingType::RETIRADA,
                meter_id: @contracting_request.old_subscriber.meter_id,
                reading_route_id: @contracting_request.old_subscriber.reading_route_id,
                reading_sequence: @contracting_request.old_subscriber.reading_sequence,
                reading_variant:  @contracting_request.old_subscriber.reading_variant,
                reading_date: @contracting_request.water_supply_contract.try(:installation_date).strftime("%d/%m/%Y %H:%M"),
                reading_index: @contracting_request.water_supply_contract.try(:installation_index),
                reading_index_1: rdg_1 ? rdg_1.try(:reading_index) : 0,
                reading_index_2: rdg_2 ? rdg_2.try(:reading_index) : 0,
                reading_1: rdg_1,
                reading_2: rdg_2,
                created_by: @contracting_request.try(:created_by)
              )
          elsif @contracting_request.old_subscriber.readings.last.reading_type_id == ReadingType::RETIRADA and @contracting_request.old_subscriber.readings.last.billable?
            @contracting_request.old_subscriber.readings.last.update_attributes(billing_period_id: @billing_period.id,
              reading_date: @contracting_request.water_supply_contract.try(:installation_date).strftime("%d/%m/%Y %H:%M"),
              reading_index: @contracting_request.water_supply_contract.try(:installation_index),
              reading_index_1: rdg_1 ? rdg_1.try(:reading_index) : 0,
              reading_index_2: rdg_2 ? rdg_2.try(:reading_index) : 0,
              reading_1: rdg_1,
              reading_2: rdg_2
              )
          end
        else
          @water_supply_contract.contracted_tariffs.destroy_all

          _tariff_type_ids.each do |r|
            _tariff_type = TariffType.find(r)
            _billable_items.each do |b|
              tariffs = Tariff.availables_to_project_type_document_caliber(b,@contracting_request.project_id,_tariff_type.id,1,@caliber.id)
              tariffs.each do |a|
                if !@water_supply_contract.tariffs.include?(a)
                  @water_supply_contract.tariffs << a
                end
              end
            end
          end
        end

        response_hash = { water_supply_contract: @water_supply_contract }
        response_hash[:tariff_scheme] = @tariff_scheme
        response_hash[:caliber] = @caliber.caliber
        response_hash[:meter] = @meter
        # response_hash[:meters_subscriber] = data_meters
        response_hash[:meter_model] = @meter_model
        response_hash[:meter_brand] = @meter_brand.try(:brand)
        response_hash[:tariff_type] = @tariff_scheme.tariff_type
        # response_hash[:tariff] = @tariff.fixed_fee.to_s if @tariff
        # response_hash[:billing_frequency] = @tariff.billing_frequency.name if @tariff
        respond_to do |format|
          format.html { redirect_to @water_supply_contract.contracting_request, notice: crud_notice( t('activerecord.attributes.water_supply_contract.created'), @water_supply_contract) }
          format.json { render json: response_hash, status: :created, location: @water_supply_contract.contracting_request }
        end
      else
        respond_to do |format|
          format.html { redirect_to @water_supply_contract.contracting_request, notice: crud_notice( t('activerecord.attributes.water_supply_contract.created'), @water_supply_contract) }
          format.json { render json: @water_supply_contract.errors, status: :unprocessable_entity }
        end
      end

    end

    # DELETE /water_supply_contracts/1
    # DELETE /water_supply_contracts/1.json
    def destroy
      @water_supply_contract = WaterSupplyContract.find(params[:id])
      @water_supply_contract.destroy

      respond_to do |format|
        format.html { redirect_to water_supply_contracts_url }
        format.json { head :no_content }
      end
    end

    private
    def manage_filter_state
      # subscribers
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # no
      if params[:No]
        session[:No] = params[:No]
      elsif session[:No]
        params[:No] = session[:No]
      end
      # subscriber
      if params[:Subscriber]
        session[:Subscriber] = params[:Subscriber]
      elsif session[:Subscriber]
        params[:Subscriber] = session[:Subscriber]
      end
      # meters
      if params[:Meter]
        session[:Meter] = params[:Meter]
      elsif session[:Meter]
        params[:Meter] = session[:Meter]
      end
      # tariff_schemes
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
      # calibers
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
    end

    def inverse_gis_search(gis)
      _numbers = []
      # Add numbers found
      WaterSupplyContract.where('gis_id LIKE ?', "#{gis}").each do |i|
        _numbers = _numbers << i.offer_gis
      end
      _numbers = _numbers.blank? ? gis : _numbers
    end

    def subscribers_dropdown
      Subscriber.where(office_id: current_offices_ids)
    end

    def reading_routes_dropdown
      ReadingRoute.where(project_id: current_projects_ids)
    end

    def meters_dropdown
      Meter.where(office_id: current_offices_ids)
    end

    def tariff_schemes_dropdown
      TariffScheme.where(project_id: current_projects_ids)
    end

    def calibers_dropdown
      Caliber.all
    end
  end
end
