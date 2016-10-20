require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class ContractingRequestsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :update_province_textfield_from_town,
                                                :update_province_textfield_from_zipcode,
                                                :update_province_textfield_from_street_directory,
                                                :update_country_textfield_from_region,
                                                :update_region_textfield_from_province,
                                                :validate_fiscal_id_textfield,
                                                :validate_r_fiscal_id_textfield,
                                                :et_validate_fiscal_id_textfield,
                                                :cr_generate_no,
                                                :show_test,
                                                :next_status,
                                                :initial_inspection,
                                                :initial_billing,
                                                :inspection_billing,
                                                :billing_instalation,
                                                :instalation_subscriber,
                                                :contracting_request_pdf,
                                                :bill,
                                                :update_bill,
                                                :biller_pdf,
                                                :get_caliber,
                                                :update_old_subscriber,
                                                :dn_update_from_invoice,
                                                :initial_complete,
                                                :billing_complete
                                              ]

    helper_method :sort_column

    def dn_update_from_invoice


      invoice_items = JSON.parse(params[:arr_invoice]) #INVOICEITEM TOTAL
      #parsed_json = ActiveSupport::JSON.decode(params[:arr_invoice])

      @invoice_items_updated = []

      #Deserialize All and guardar in array UPDATED ROW #####DESERIALIZE AND UPDATE ROW
      invoice_items.each_with_index do |item, index|

        qty = item["qty"].to_f / 10000
        pce = item["pce"].to_f / 10000
        tax = item["tax"].to_f / 10000
        disc = item["disc"].to_f / 10000
        disc_per = item["disc_per"].to_f / 10000
        invoice_id = item["invoice_id"].to_f
        invoice_item_id = item["invoice_item_id"].to_f

        #Make calculos and push array
        net_price = pce - disc
        amount = qty * net_price
        bonus =  (disc_per / 100) * amount if !disc_per.blank?
        total = amount - bonus

        amount = number_with_precision(amount.round(4), precision: 4)
        total = number_with_precision(total.round(4), precision: 4)

        @invoice_items_updated[index] = {qty: qty, pce: pce, tax: tax, disc: disc, disc_per: disc_per, invoice_id: invoice_id, invoice_item_id: invoice_item_id, amount: amount.to_s, total: total.to_s, changed: item["changed"] }
      end

      subtotal = 0
      @invoice_items_updated.each do |invoice_item|
        subtotal += invoice_item[:total].gsub(/,/,".").to_f
      end

      total = 0
      @tax_breakdown = []
      sum_total_invoice = 0
      @invoice_items_updated.group_by{|t| t[:tax]}.map do |tax|
        tax_unique = tax[0].to_f
        tax[1][0][:total].gsub(/,/,".").to_f
        total = tax[1].sum{|j| j[:total].gsub(/,/,".").to_f}
        tax_total = total * (tax_unique/100)

        sum_total_invoice = sum_total_invoice + tax_total

        @tax_breakdown.push({tax: tax_unique, total: total, tax_total: tax_total, tax_count: tax[1].count })
      end

      @tax_breakdown.to_json
      @invoice_items_updated.to_json

      @data_return = {invoice_items: @invoice_items_updated, tax_breakdown: @tax_breakdown, subtotal: subtotal, total: sum_total_invoice+subtotal}

      respond_to do |format|
        format.html
        format.json { render json: @data_return } #@invoice_items_updated
      end
    end


    def bill
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      @bill = @water_supply_contract.bill
    end

    # PDF Contracting Request
    def contracting_request_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "SCR-#{@contracting_request.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    # PDF Subscriber
    def contracting_subscriber_pdf
      @contract = ContractingRequest.find(params[:id])
      @subscriber = @contract.subscriber
      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "SCR-#{@subscriber}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    # PDF Biller
    def biller_pdf
     @contracting_request = ContractingRequest.find(params[:id])
     @water_supply_contract = @contracting_request.water_supply_contract
     @bill = @water_supply_contract.bill
     respond_to do |format|
       format.pdf {
         send_data render_to_string, filename: "SCR-#{@contracting_request.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
       }
     end
    end

    # Change contracting request status
    def next_status
      @contracting_request = ContractingRequest.find(params[:id])
      @contracting_request.status_control
      response_hash = { contracting_request: @contracting_request }
      response_hash[:water_supply_contract] = @contracting_request.water_supply_contract if @contracting_request.water_supply_contract
      response_hash[:client] = @contracting_request.client if @contracting_request.client
      respond_to do |format|
      #   format.html # does not exist! JSON only
        format.json { render json: response_hash }
      end
    end

    def initial_complete
      @contracting_request = ContractingRequest.find(params[:id])
      @contracting_request.status_control("complete");
      if @contracting_request.save
        respond_to do |format|
          format.json { render json: @contracting_request }
        end
      else
        respond_to do |format|
          format.json { render json: @contracting_request.errors.as_json, status: :unprocessable_entity }
        end
      end
    end

    def billing_complete
      @contracting_request = ContractingRequest.find(params[:id])
      @contracting_request.status_control("complete");
      if @contracting_request.save
        respond_to do |format|
          format.json { render json: @contracting_request }
        end
      else
        respond_to do |format|
          format.json { render json: @contracting_request.errors.as_json, status: :unprocessable_entity }
        end
      end
    end

    # Create work order inspection
    def initial_inspection
      @contracting_request = ContractingRequest.find(params[:id])
      # current_user_id = current_user.id if !current_user.nil?
      @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25, #WorkOderType inspection Nestor
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 132, # Nestor
                                    work_order_area_id: 3, # Nestor
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.charge_account.first,
                                    in_charge_id: 1
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                  )
      if @work_order.save(:validate => false)
        @contracting_request.work_order = @work_order
        @contracting_request.status_control
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          response_hash[:work_order] = @work_order
          response_hash[:work_order_status] = @work_order.work_order_status
          respond_to do |format|
            format.json { render json: response_hash }
          end
        else
          respond_to do |format|
            format.json { render :json => { :errors => @contracting_request.errors.as_json }, :status => 420 }
          end
        end
      else
        respond_to do |format|
          format.json { render :json => { :errors => @work_order.errors.as_json }, :status => 420 }
        end
      end
    end

    # Create contracting request bill
    def inspection_billing
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      # tariffs_by_scheme = Tariff.where(tariff_scheme_id: @water_supply_contract.tariff_scheme.id)
      # tariffs_contract = tariffs_by_scheme.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 2}
      # tariffs_caliber = tariffs_contract.select{|t| t.caliber == @water_supply_contract.meter.caliber}
      # tariffs_by_biller = tariffs_caliber.group_by{|t| t.try(:billable_item).try(:biller_id)}
      # tariffs_by_biller = Tariff.by_contract(@water_supply_contract)
      # tariffs_by_biller = @water_supply_contract.tariffs_contract

      # @bill = Bill.create(project_id: @contracting_request.project_id,
      #                     invoice_status_id: 1, #Nestor
      #                     bill_no: bill_next_no(@contracting_request.project),
      #                     bill_date: Date.today)

      # tariffs_by_biller.each do |tariffs_biller|
      #   invoice = Invoice.create(
      #     bill_id: @bill.id,
      #     invoice_no: "",
      #     invoice_date: Date.today,
      #     invoice_status_id: 1, #Nestor
      #     invoice_type_id: 1,
      #     tariff_scheme_id: @water_supply_contract.tariff_scheme.id,
      #     company_id: tariffs_biller[0]
      #   ) #Nestor
      #   tariffs_biller[1].each do |tariff|
      #     InvoiceItem.create(
      #       invoice_id: invoice.id,
      #       code: tariff.try(:billable_item).try(:billable_concept).try(:code),
      #       description: tariff.try(:billable_item).try(:billable_concept).try(:name),
      #       quantity: 1,
      #       unit_price: tariff.try(:fixed_fee),
      #       amount: tariff.try(:fixed_fee),
      #       tax_type: tariff.try(:tax_type_f).try(:tax) || 0,
      #       tax: 0,
      #       discount: tariff.try(:discount_pct_f),
      #       tariff_id: tariff.id)
      #   end
      # end
      @bill = @water_supply_contract.generate_bill

      if @bill
        @contracting_request.status_control;
        if @contracting_request.save
          respond_to do |format|
            format.json { render json: response_hash }
            format.js {}
          end
        else
          respond_to do |format|
            format.json { render json: @water_supply_contract.errors.as_json, status: :unprocessable_entity }
          end
        end
      end
    end

    def initial_billing
      @contracting_request = ContractingRequest.find(params[:id])
      # @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
      #                               work_order_type_id: 1, #WorkOderType inspection Nestor
      #                               work_order_status_id: 1, #WorkOderStatus initial Nestor
      #                               work_order_labor_id: 1, # Nestor
      #                               project_id: @contracting_request.project_id,
      #                               client_id: @contracting_request.client.id, # ¿¿??
      #                               description:  "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
      #                               organization_id: @contracting_request.project.organization_id,
      #                               in_charge_id: 1
      #                               # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
      #                             )
      @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25, #WorkOderType inspection Nestor
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 132, # Nestor
                                    work_order_area_id: 3, # Nestor
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.charge_account.first,
                                    in_charge_id: 1
                                    )
      if @work_order.save(:validate => false)
        @contracting_request.work_order = @work_order;

        @water_supply_contract = @contracting_request.water_supply_contract

        @bill = @water_supply_contract.generate_bill

        if @bill
          @contracting_request.status_control("billing");
          if @contracting_request.save
            respond_to do |format|
              format.json { render json: @bill }
              format.js {}
            end
          else
            respond_to do |format|
              format.json { render json: @water_supply_contract.errors.as_json, status: :unprocessable_entity }
            end
          end
        end
      else
        respond_to do |format|
          format.json { render json: @work_order.errors.as_json, status: :unprocessable_entity }
        end
      end

    end

    def update_bill
      @contracting_request = ContractingRequest.find(params[:id])
      params["invoice_item"].each do |item|
         invoice_item = InvoiceItem.find_by_id(item[0])
         invoice_item.update_attributes(item[1]) if invoice_item
      end
      respond_to do |format|
        format.json { render json: params["invoice_item"]}
      end
    end

    # Create instalation work order
    def billing_instalation
      @contracting_request = ContractingRequest.find(params[:id])
      # @work_order = WorkOrder.new( order_no: wo_next_no(@contracting_request.project),
      #                              work_order_type_id: 2, #WorkOderType inspection Nestor
      #                              work_order_status_id: 1, #WorkOderStatus initial Nestor
      #                              work_order_labor_id: 1, # Nestor
      #                              charge_account_id: 1, # Nestor
      #                              project_id: @contracting_request.project_id,
      #                              client_id: @contracting_request.client.id, # ¿¿??
      #                              description: "Solicitud de contratacion n. " + @contracting_request.request_no,
      #                              organization_id: @contracting_request.project.organization_id,
      #                              in_charge_id: 1)
      # if @work_order.save
        # @contracting_request.water_supply_contract.work_order_id = @work_order.id
        # @contracting_request.water_supply_contract.save
        @contracting_request.status_control
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          # response_hash[:work_order] = @work_order
          # response_hash[:work_order_status] = @work_order.work_order_status
          respond_to do |format|
            format.json { render json: response_hash }
          end
        else
          respond_to do |format|
            format.json { render :json => { :errors => @contracting_request.errors.as_json }, :status => 420 }
          end
        end
      # else
      #   respond_to do |format|
      #     format.json { render :json => { :errors => @work_order.errors.as_json }, :status => 420 }
      #   end
      # end
    end

    # Create subscriber
    def instalation_subscriber
      @contracting_request = ContractingRequest.find(params[:id])
      # @contracting_request.to_subscriber
      @contracting_request.status_control
      if @contracting_request.save
        response_hash = { subscriber: @contracting_request.subscriber }
        respond_to do |format|
          format.json { render json: response_hash }
        end
      else
        respond_to do |format|
          format.json { render :json => { :errors => @contracting_request.errors.as_json }, :status => 420 }
        end
      end
    end

    def get_caliber
      meter = Meter.find(params[:id])
      caliber = meter.caliber
      respond_to do |format|
        format.json { render json: caliber }
      end
    end

    # Update subscriber data if old subscriber exits
    def update_old_subscriber
      @subscriber = Subscriber.find(params[:id])
      # @contracting_request = @subscriber.try(:water_supply_contract).try(:contracting_request)
      @json_data = { "subscriber" => @subscriber }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { "contracting_request" => "" }}
        end
    end

    # Update country text field at view from region select
    def update_country_textfield_from_region
      @region = Region.find(params[:id])
      @country = Country.find(@region.country)

      respond_to do |format|
        format.html # update_country_textfield_from_region.html.erb does not exist! JSON only
        format.json { render json: @country }
      end
    end

    # Update region and country text fields at view from town select
    def update_region_textfield_from_province
      @province = Province.find(params[:id])
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update province, region and country text fields at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @zipcodes = Zipcode.find(@town.zipcode_ids)
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id, "zipcode_ids" => @zipcodes.map(&:id) }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { "province_id" => "", "region_id" => "", "country_id" => "" } }
        end
    end

    # Update town, province, region and country text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update fileds from street_directory
    def update_province_textfield_from_street_directory

      if params[:id] == "0"
        @json_data = []
      else
        @street_directory = StreetDirectory.find(params[:id])
        @street_type = StreetType.find(@street_directory.street_type)
        @street_name = StreetDirectory.find(params[:id]).street_name
        @town = Town.find(@street_directory.town)
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id, "street_type_id" => @street_type.id, "street_name" => @street_name}
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update contract number at view (generate_code_btn)
    def cr_generate_no
      project = params[:id]
      # Builds code, if possible
      code = project == '$' ? '$err' : cr_next_no(project)
      @json_data = { "code" => code }
      render json: @json_data
    end

      ##########APPLICATION_CONTROLLER.RB##########
    # Contracting request no
    def cr_next_no(project)
      year = Time.new.year
      code = ''
      # Builds code, if possible
      project_code = Project.find(project).project_code rescue '$'
      if project_code == '$'
        code = '$err'
      else
        project = project_code.rjust(12, '0')
        year = year.to_s if year.is_a? Fixnum
        year = year.rjust(4, '0')
        last_no = ContractingRequest.where("request_no LIKE ?", "#{project}#{year}%").order(:request_no).maximum(:request_no)
        if last_no.nil?
          code = project + year + '000001'
        else
          last_no = last_no[16..21].to_i + 1
          code = project + year + last_no.to_s.rjust(6, '0')
        end
      end
      code
    end

    # Search Entity
    def validate_fiscal_id_textfield
      id = ''
      fiscal_id = ''
      name = ''
      street_type_id = ''
      street_name = ''
      street_number = ''
      building = ''
      floor = ''
      floor_office = ''
      zipcode_id = ''
      town_id = ''
      province_id = ''
      region_id = ''
      country_id = ''
      phone = ''
      fax = ''
      cellular = ''
      email = ''
      # organization_id = ''

      if params[:id] == '0'
        id = '$err'
        fiscal_id = '$err'
      else
        if session[:organization] != '0'
          @entity = Entity.find_by_fiscal_id_and_organization(params[:id], session[:organization])
        else
          @entity = Entity.find_by_fiscal_id(params[:id])
        end
        if @entity.nil?
          id = '$err'
          fiscal_id = '$err'
        else
          id = @entity.id
          fiscal_id = @entity.fiscal_id
          if @entity.entity_type_id < 2
            name = @entity.full_name
          else
            name = @entity.company
          end
          street_type_id = @entity.street_type_id
          street_name = @entity.street_name
          street_number = @entity.street_number
          building = @entity.building
          floor = @entity.floor
          floor_office = @entity.floor_office
          zipcode_id = @entity.zipcode_id
          town_id = @entity.town_id
          province_id = @entity.province_id
          region_id = @entity.region_id
          country_id = @entity.country_id
          phone = @entity.phone
          fax = @entity.fax
          cellular = @entity.cellular
          email = @entity.email
          # organization_id = @entity.organization_id
          street_directory = StreetDirectory.find_by_street_name(@entity.street_name)
        end
      end
      @json_data = {  "id" => id,
                      "fiscal_id" => fiscal_id,
                      "name" => name,
                      "street_type_id" => street_type_id,
                      "street_name" => street_name,
                      "street_number" => street_number,
                      "building" => building,
                      "floor" => floor,
                      "floor_office" => floor_office,
                      "zipcode_id" => zipcode_id,
                      "town_id" => town_id,
                      "province_id" => province_id,
                      "region_id" => region_id,
                      "country_id" => country_id,
                      "phone" => phone,
                      "fax" => fax,
                      "cellular" => cellular,
                      "email" => email,
                      "street_directory_id" => street_directory.try(:id)
                      # "organization_id" => organization_id
                    }

      respond_to do |format|
        format.html # validate_fiscal_id_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Search Representative Entity
    def validate_r_fiscal_id_textfield
      id = ''
      fiscal_id = ''
      first_name = ''
      last_name = ''

      if params[:id] == '0'
        id = '$err'
        fiscal_id = '$err'
      else
        if session[:organization] != '0'
          @entity = Entity.find_by_fiscal_id_and_organization(params[:id], session[:organization])
        else
          @entity = Entity.find_by_fiscal_id(params[:id])
        end
        if @entity.nil?
          id = '$err'
          fiscal_id = '$err'
        else
          id = @entity.id
          fiscal_id = @entity.fiscal_id
          first_name = @entity.first_name
          last_name = @entity.last_name
        end
      end

      @json_data = {  "r_id" => id,
                      "r_fiscal_id" => fiscal_id,
                      "r_first_name" => first_name,
                      "r_last_name" => last_name
                    }

      respond_to do |format|
        format.html # validate_fiscal_id_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

        # Validate entity fiscal id (modal)
    def et_validate_fiscal_id_textfield
      fiscal_id = params[:id]
      dc = ''
      f_id = 'OK'
      f_name = ''

      if fiscal_id == '0'
        f_id = '$err'
      else
        dc = fiscal_id_dc(fiscal_id)
        if dc == '$par' || dc == '$err'
          f_id = '$err'
        else
          if dc == '$uni'
            f_id = '??'
          end
          f_name = fiscal_id_description(fiscal_id[0])
          if f_name == '$err'
            f_name = I18n.t("ag2_admin.entities.fiscal_name")
          end
        end
      end

      @json_data = { "fiscal_id" => f_id, "fiscal_name" => f_name }
      render json: @json_data
    end

    # GET /requests
    # GET /requests.json
    def index
      manage_filter_state
      request_type = params[:RequestType]
      no = params[:No]
      project = params[:Project]
      request_status = params[:RequestStatus]
      client_info = params[:ClientInfo]
      sort = params[:sort]
      direction = params[:direction]

      @projects = projects_dropdown if @project.nil?
      @request_statuses = request_statuses_dropdown if @request_status.nil?
      @request_types = request_types_dropdown if @request_type.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = ContractingRequest.search do
        with :project_id, current_projects
        # fulltext
        if !client_info.blank?
          fulltext client_info
        end
        if !no.blank?
          with :request_no, no
        end
        if !request_status.blank?
          with :contracting_request_status_id, request_status
        end
        if !request_type.blank?
          with :contracting_request_type_id, request_type
        end
        if !sort.blank? and !direction.blank?
          order_by sort, direction
        else
          order_by :request_no, :desc
        end
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @contracting_requests = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_requests }
        format.js
      end
    end

    # GET /contracting_requests/1
    # GET /contracting_requests/1.json
    def show
      @breadcrumb = 'read'
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract || WaterSupplyContract.new
      @subscriber = @contracting_request.try(:subscriber) || Subscriber.new
      @projects = current_projects
      @projects_ids = current_projects_ids

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request }
      end
    end

    def show_test
      @breadcrumb = 'read'
    end

    # GET /contracting_requests/new
    # GET /contracting_requests/new.json
    def new
      @breadcrumb = 'create'
      @contracting_request = ContractingRequest.new
      @projects = current_projects
      @projects_ids = current_projects_ids
      _subscribers = Subscriber.where(office_id: current_offices_ids)
      @subscribers = Subscriber.where(office_id: current_offices_ids).availables if !_subscribers.empty?
      @service_points = ServicePoint.where(office_id: current_offices_ids)
      @offices = current_offices
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request }
      end

    end

    # GET /contracting_requests/1/edit
    def edit
      @breadcrumb = 'update'
      @contracting_request = ContractingRequest.find(params[:id])
      @projects = current_projects
      @projects_ids = current_projects_ids
      _subscribers = Subscriber.where(office_id: current_offices_ids)
      @subscribers = Subscriber.where(office_id: current_offices_ids).availables if !_subscribers.empty?
      @service_points = ServicePoint.where(office_id: current_offices_ids)
      @offices = current_offices
    end

    # POST /requests
    # POST /requests.json
    def create
      @breadcrumb = 'create'
      @projects = current_projects
      @projects_ids = current_projects_ids
      _subscribers = Subscriber.where(office_id: current_offices_ids)
      @subscribers = Subscriber.where(office_id: current_offices_ids).availables if !_subscribers.empty?
      @service_points = ServicePoint.where(office_id: current_offices_ids)
      @offices = current_offices
      @contracting_request = ContractingRequest.new(params[:contracting_request])
      @contracting_request.contracting_request_status_id = 1
      respond_to do |format|
        if @contracting_request.save
          @contracting_request.to_subrogation if @contracting_request.contracting_request_type_id == ContractingRequestType::SUBROGATION
          format.html { redirect_to @contracting_request, notice: t('activerecord.attributes.contracting_request.create')}
          format.json { render json: @contracting_request, status: :created, location: @contracting_request }
        else
          format.html { render action: "new" }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /contracting_requests/1
    # PUT /contracting_requests/1.json
    def update
      @breadcrumb = 'update'
      @contracting_request = ContractingRequest.find(params[:id])

      respond_to do |format|
        if @contracting_request.update_attributes(params[:contracting_request])
          format.html { redirect_to @contracting_request, notice: t('activerecord.attributes.contracting_request.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /contracting_requests/1
    # DELETE /contracting_requests/1.json
    def destroy
      @contracting_request = ContractingRequest.find(params[:id])
      @contracting_request.destroy

      respond_to do |format|
        format.html { redirect_to contracting_requests_url }
        format.json { head :no_content }
      end
    end

    private

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def manage_filter_state
      # id_fiscal
      if params[:IdFiscal]
        session[:IdFiscal] = params[:IdFiscal]
      elsif session[:IdFiscal]
        params[:IdFiscal] = session[:IdFiscal]
      end

      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end

    end

    def sort_column
      ContractingRequest.column_names.include?(params[:sort]) ? params[:sort] : "request_no"
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def request_statuses_dropdown
      _request_statuses = ContractingRequestStatus.order(:name)
    end

    def request_types_dropdown
      _request_types = ContractingRequestType.order(:description)
    end

    def work_orders_dropdown
      _work_orders = WorkOrder.order(:order_no)
    end

  end
end
