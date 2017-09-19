require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionContractsController < ApplicationController
    # GET /water_connection_contracts
    # GET /water_connection_contracts.json
    def index
      @water_connection_contracts = WaterConnectionContract.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connection_contracts }
      end
    end
  
    # GET /water_connection_contracts/1
    # GET /water_connection_contracts/1.json
    def show
      @water_connection_contract = WaterConnectionContract.find(params[:id])
      @water_connection_contract_items = @water_connection_contract.water_connection_contract_items

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @water_connection_contract }
      end
    end
  
    # GET /water_connection_contracts/new
    # GET /water_connection_contracts/new.json
    # def new
    #   @water_connection_contract = WaterConnectionContract.new
  
    #   respond_to do |format|
    #     format.html # new.html.erb
    #     format.json { render json: @water_connection_contract }
    #   end
    # end
  
    # # GET /water_connection_contracts/1/edit
    # def edit
    #   @water_connection_contract = WaterConnectionContract.find(params[:id])
    # end
  
    # POST /water_connection_contracts
    # POST /water_connection_contracts.json
    def create
      @breadcrumb = 'create'
      @contracting_request = ContractingRequest.find(params[:water_connection_contract][:contracting_request_id])
      @water_connection_contract = WaterConnectionContract.new(params[:water_connection_contract])
      _project = @contracting_request.project_id
      _type = @contracting_request.contracting_request_type_id
      @water_connection_contract.contract_no = contract_next_no(_project,_type) if _type == ContractingRequestType::CONNECTION
      @water_connection_contract.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @water_connection_contract.save
          @sale_offer = @water_connection_contract.to_sale_offer
          @water_connection_contract.update_attributes(sale_offer_id: @sale_offer.id)
          format.html { redirect_to @water_connection_contract, notice: 'Water connection contract was successfully created.' }
          format.json { render json: @water_connection_contract, status: :created, location: @water_connection_contract }
        else
          format.html { render action: "new" }
          format.json { render json: @water_connection_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /water_connection_contracts/1
    # PUT /water_connection_contracts/1.json

    def update
      @breadcrumb = 'update'
      @water_connection_contract = WaterConnectionContract.find(params[:id])
      @contracting_request = ContractingRequest.find(params[:water_connection_contract][:contracting_request_id])
      @water_connection_contract.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @water_connection_contract.update_attributes(params[:water_connection_contract])
          if @water_connection_contract.sale_offer
            @water_connection_contract.sale_offer.update_attributes(
              charge_account_id: @water_connection_contract.water_connection_type_id == 1 ? 10763 : @water_connection_contract.water_connection_type_id == 2 ? 10764 : 10765
            )
          end
          format.html { redirect_to @water_connection_contract,
                        notice: (crud_notice('updated', @water_connection_contract) + "#{undo_link(@water_connection_contract)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @water_connection_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /water_connection_contracts/1
    # DELETE /water_connection_contracts/1.json
    def destroy
      @water_connection_contract = WaterConnectionContract.find(params[:id])

      respond_to do |format|
        if @water_connection_contract.destroy
          format.html { redirect_to water_connection_contracts_url,
                      notice: (crud_notice('destroyed', @water_connection_contract) + "#{undo_link(@water_connection_contract)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to water_connection_contracts_url, alert: "#{@water_connection_contract.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @water_connection_contract.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
