require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class WaterConnectionContractsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:water_connection_contract_view_report]


    def water_connection_contract_view_report
      manage_filter_state
      no = params[:No]
      order = params[:Order]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      @tariff_schemes = tariff_schemes_dropdown if @tariff_schemes.nil?
      @calibers = calibers_dropdown if @calibers.nil?

      # ContractingRequest for current projects
      current_contracting_request = ContractingRequest.where(project_id: current_projects_ids).map(&:id)

      @search = WaterConnectionContract.search do
        if !current_contracting_request.blank?
          with :contracting_request_id, current_contracting_request
        end
        fulltext params[:search]
        if !no.blank?
          with(:request_no).starting_with(no)
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
        paginate :page => params[:page] || 1, :per_page => WaterConnectionContract.count
      end
      # @wcc_report = @search.results
      wcc_ids = []
      @search.hits.each do |i|
        wcc_ids << i.result.id
      end
      @wcc_report = WaterConnectionContract.with_these_ids(wcc_ids)

      title = t("activerecord.models.water_connection_contract.few")
      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                    filename: "#{title}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline' }
      end
    end

    # GET /water_connection_contracts
    # GET /water_connection_contracts.json
    def index
      manage_filter_state
      no = params[:No]
      order = params[:Order]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      @tariff_schemes = tariff_schemes_dropdown if @tariff_schemes.nil?
      @calibers = calibers_dropdown if @calibers.nil?

      # ContractingRequest for current projects
      current_contracting_request = ContractingRequest.where(project_id: current_projects_ids).map(&:id)

      @search = WaterConnectionContract.search do
        if !current_contracting_request.blank?
          with :contracting_request_id, current_contracting_request
        end
        fulltext params[:search]
        if !no.blank?
          with(:request_no).starting_with(no)
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
      @water_connection_contracts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @water_connection_contracts }
        format.js
      end
    end

    # GET /water_connection_contracts/1
    # GET /water_connection_contracts/1.json
    def show
      @breadcrumb = 'read'
      @water_connection_contract = WaterConnectionContract.find(params[:id])
      @water_connection_contract_items = @water_connection_contract.water_connection_contract_items.paginate(:page => params[:page], :per_page => per_page).order('id')

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
              charge_account_id: @water_connection_contract.water_connection_type_id == WaterConnectionType::SUM ? 10763 : @water_connection_contract.water_connection_type_id == WaterConnectionType::SAN ? 10764 : 10765
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
      WaterConnectionContract.where('gis_id LIKE ?', "#{gis}").each do |i|
        _numbers = _numbers << i.offer_gis
      end
      _numbers = _numbers.blank? ? gis : _numbers
    end

    def tariff_schemes_dropdown
      TariffScheme.where(project_id: current_projects_ids)
    end

    def calibers_dropdown
      Caliber.all
    end
  end
end
