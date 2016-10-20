require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterSupplyContractsController < ApplicationController
    # GET /water_supply_contracts
    # GET /water_supply_contracts.json
    def index
      @water_supply_contracts = WaterSupplyContract.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_supply_contracts }
      end
    end

    # GET /water_supply_contracts/1
    # GET /water_supply_contracts/1.json
    # def show
    #   @water_supply_contract = WaterSupplyContract.find(params[:id])

    #   respond_to do |format|
    #     format.html # show.html.erb
    #     format.json { render json: @water_supply_contract }
    #   end
    # end

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
      @meter = Meter.where(id: params[:water_supply_contract][:meter_id])
      @meter_model = @meter.blank? ? nil : @meter.first.try(:meter_model)
      @caliber = @meter.blank? ? Caliber.find(params[:water_supply_contract][:caliber_id]) : @meter.first.try(:caliber)
      # @billable_item = BillableItem.find_by_project_id_and_billable_concept_id(@contracting_request.project_id, 3) # 3 for contrataction
      # @tariff = Tariff.find_by_tariff_scheme_id_and_caliber_id_and_billable_item_id(@tariff_scheme.id, @caliber.id, @billable_item.id)
      @water_supply_contract = WaterSupplyContract.new(params[:water_supply_contract])
      # @water_supply_contract.tariff_id = @tariff.try(:id)
      if @water_supply_contract.save
        response_hash = { water_supply_contract: @water_supply_contract }
        response_hash[:tariff_scheme] = @tariff_scheme
        response_hash[:caliber] = @caliber.caliber
        response_hash[:meter] = @meter
        response_hash[:meter_model] = @meter_model
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
      @contracting_request = ContractingRequest.find(params[:water_supply_contract][:contracting_request_id])
      @tariff_scheme = TariffScheme.find(params[:water_supply_contract][:tariff_scheme_id])
      @meter = Meter.find(params[:water_supply_contract][:meter_id])
      @meter_model = @meter.try(:meter_model)
      @caliber = @meter.try(:caliber) || Caliber.find(params[:water_supply_contract][:caliber_id])
      # @billable_item = BillableItem.find_by_project_id_and_billable_concept_id(@contracting_request.project_id, 3) # 3 for contrataction
      # @tariff = Tariff.find_by_tariff_scheme_id_and_caliber_id_and_billable_item_id(@tariff_scheme.id, @caliber.id, @billable_item.id)
      @water_supply_contract = WaterSupplyContract.find(params[:id])
      # @water_supply_contract.tariff_id = @tariff.try(:id)

      if @water_supply_contract.update_attributes(params[:water_supply_contract])
        response_hash = { water_supply_contract: @water_supply_contract }
        response_hash[:tariff_scheme] = @tariff_scheme
        response_hash[:caliber] = @caliber.caliber
        response_hash[:meter] = @meter
        response_hash[:meter_model] = @meter_model
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
  end
end
