require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class ContractingRequestsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :set_defaults_for_new_and_edit, only: [:new, :edit, :new_connection, :edit_connection]
    before_filter :set_defaults_for_show, only: :show
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :update_tariff_type_select_from_billing_concept,
                                                :update_province_textfield_from_town,
                                                :update_province_textfield_from_zipcode,
                                                :update_province_textfield_from_street_directory,
                                                :update_country_textfield_from_region,
                                                :update_region_textfield_from_province,
                                                :update_subscriber_from_service_point,
                                                :update_connection_from_street_directory,
                                                :update_bank_offices_from_bank,
                                                :update_tariff_schemes_from_use,
                                                :validate_fiscal_id_textfield,
                                                :validate_r_fiscal_id_textfield,
                                                :et_validate_fiscal_id_textfield,
                                                :cr_generate_no,
                                                :show_test,
                                                :next_status,
                                                :complete_status,
                                                :ot_connection_inspection,
                                                :initial_inspection,
                                                :ot_cancellation,
                                                :ot_installation,
                                                :ot_connection_installation,
                                                :initial_billing,
                                                :initial_billing_cancellation,
                                                :connection_billing,
                                                :inspection_billing,
                                                :inspection_billing_cancellation,
                                                :billing_connection,
                                                :billing_instalation,
                                                :billing_instalation_cancellation,
                                                :new_subscriber_cancellation,
                                                :complete_connection,
                                                :instalation_subscriber,
                                                :bill,
                                                :bill_cancellation,
                                                :update_bill,
                                                :get_caliber,
                                                :update_old_subscriber,
                                                :initial_complete,
                                                :billing_complete,
                                                :cr_find_meter,
                                                :cr_find_subscriber,
                                                :cr_find_service_point,
                                                :next_status,
                                                :subrogation,
                                                :contracting_request_report,
                                                :contracting_request_complete_report,
                                                :biller_pdf,
                                                :contracting_request_pdf,
                                                :contracting_request_connection_pdf,
                                                :contracting_subscriber_pdf,
                                                :refresh_status,
                                                :refresh_connection_status,
                                                :cr_calculate_flow,
                                                :cr_generate_invoice_from_offer,
                                                :void_bill_connection,
                                                :bill_connection_create,
                                                :bill_assign_invoice_from_offer,
                                                :contract_pdf,
                                                :sepa_pdf,
                                                :serpoint_generate_no,
                                                :new_connection,
                                                :edit_connection,
                                                :cr_check_iban,
                                                :cr_load_form_dropdowns,
                                                :cr_load_show_dropdowns]
    # Helper methods for
    helper_method :sort_column
    # => search available meters
    helper_method :available_meters_for_contract
    helper_method :available_meters_for_subscriber

    # Check IBAN
    def cr_check_iban
      iban = check_iban(params[:country], params[:dc], params[:bank], params[:office], params[:account])
      # Setup JSON
      @json_data = { "iban" => iban }
      render json: @json_data
    end

    def refresh_status
      @contracting_request = ContractingRequest.find(params[:id])
      response_hash = { contracting_request: @contracting_request }
      response_hash[:client_debt] = number_with_precision(@contracting_request.client.total_debt_unpaid, precision: 4, delimiter: I18n.locale == :es ? "." : ",") if @contracting_request.client
      response_hash[:work_order] = @contracting_request.work_order if @contracting_request.work_order
      response_hash[:work_order_status] = @contracting_request.work_order.work_order_status if @contracting_request.work_order
      response_hash[:work_order_installation] = @contracting_request.water_supply_contract.work_order if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:work_order_status_installation] = @contracting_request.water_supply_contract.work_order.work_order_status if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:work_order_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP or @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
      response_hash[:work_order_status_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first.work_order_status if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP or @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
      response_hash[:invoice_status] = @contracting_request.water_supply_contract.bill.invoices.first.invoice_status if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
      response_hash[:invoice_status_cancellation] = @contracting_request.water_supply_contract.unsubscribe_bill.invoices.first.invoice_status if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill
      response_hash[:bill] = @contracting_request.water_supply_contract.bill if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
      response_hash[:caliber] = @contracting_request.work_order.caliber if @contracting_request.work_order and @contracting_request.work_order.caliber
      response_hash[:meter_code] = @contracting_request.work_order.meter_code if @contracting_request.work_order and @contracting_request.work_order.caliber
      response_hash[:meter_installation] = @contracting_request.water_supply_contract.work_order.meter if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:meter_code_installation] = @contracting_request.water_supply_contract.work_order.meter_code if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:meter_location_installation] = @contracting_request.water_supply_contract.work_order.meter_location if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:reading_index_installation] = @contracting_request.water_supply_contract.work_order.current_reading_index if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:reading_date_installation] = @contracting_request.water_supply_contract.work_order.current_reading_date if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
      response_hash[:reading_index_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first.current_reading_index if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP or @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
      response_hash[:reading_date_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first.current_reading_date if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP or @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
      respond_to do |format|
        format.json { render json: response_hash }
      end
    end

    def refresh_connection_status
      @contracting_request = ContractingRequest.find(params[:id])
      response_hash = { contracting_request: @contracting_request }
      response_hash[:client_debt] = number_with_precision(@contracting_request.client.total_debt_unpaid, precision: 4, delimiter: I18n.locale == :es ? "." : ",") if @contracting_request.client
      response_hash[:total_sale_offer] = number_with_precision(@contracting_request.water_connection_contract.sale_offer.total, precision: 4, delimiter: I18n.locale == :es ? "." : ",") if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.sale_offer
      response_hash[:total_work_order] = number_with_precision(@contracting_request.water_connection_contract.work_order.total, precision: 4, delimiter: I18n.locale == :es ? "." : ",") if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.work_order
      response_hash[:work_order] = @contracting_request.work_order if @contracting_request.work_order
      response_hash[:work_order_status] = @contracting_request.work_order.work_order_status if @contracting_request.work_order
      response_hash[:work_order_installation] = @contracting_request.water_connection_contract.work_order if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.work_order
      response_hash[:work_order_status_installation] = @contracting_request.water_connection_contract.work_order.work_order_status if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.work_order
      response_hash[:invoice_status] = @contracting_request.water_connection_contract.bill.invoices.first.invoice_status if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.bill
      response_hash[:bill] = @contracting_request.water_connection_contract.bill if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.bill
      response_hash[:caliber] = @contracting_request.work_order.caliber if @contracting_request.work_order and @contracting_request.work_order.caliber
      response_hash[:sale_offer] = @contracting_request.water_connection_contract.sale_offer if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.sale_offer
      response_hash[:sale_offer_status] = @contracting_request.water_connection_contract.sale_offer.sale_offer_status if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.sale_offer
      response_hash[:invoice_from_offer] = @contracting_request.water_connection_contract.sale_offer.invoices if @contracting_request.water_connection_contract and @contracting_request.water_connection_contract.sale_offer
      respond_to do |format|
        format.json { render json: response_hash }
      end
    end


    def cr_calculate_flow
      @wccit = WaterConnectionContractItemType.find(params[:wcc_item_type])
      @wccoq = params[:wcc_quantity]
      @quantity_flow = @wccit.flow.to_i * @wccoq.to_i

      flow = number_with_precision(@wccit.flow, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
      quantity_flow = number_with_precision(@quantity_flow, precision: 2, delimiter: I18n.locale == :es ? "." : ",")

      # Setup JSON
      @json_data = { "flow" => flow.to_s, "quantity_flow" => quantity_flow.to_s }
      render json: @json_data
    end

    def void_bill_connection
      code = ''
      @contracting_request = ContractingRequest.find(params[:id])
      @water_connection_contract = @contracting_request.water_connection_contract
      bill = @contracting_request.water_connection_contract.bill

      bill_cancel = bill.dup
      bill_cancel.bill_no = bill_next_no(bill.project_id)
      if bill_cancel.save
        bill.invoices.each do |invoice|
          new_invoice = invoice.dup
          new_invoice.invoice_no = invoice_next_no(bill.project.company_id, bill.project.office_id)
          new_invoice.bill_id = bill_cancel.id
          new_invoice.invoice_operation_id = InvoiceOperation::CANCELATION
          new_invoice.original_invoice_id = invoice.id
          new_invoice.save
          invoice.invoice_items.each do |item|
            new_item = item.dup
            new_item.invoice_id = new_invoice.id
            new_item.price = new_item.price * -1
            new_item.save
          end
        end

        # @water_connection_contract.sale_offer.update_attributes(sale_offer_status_id: SaleOfferStatus::CANCELLATION) if @water_connection_contract.sale_offer
        @water_connection_contract.update_attributes(contract_date: nil, bill_id: nil)
        @contracting_request.update_attributes(contracting_request_status_id: ContractingRequestStatus::INITIAL)
        if code == ''
          code = I18n.t("ag2_gest.commercial_billings.generate_invoice_ok")
        end
        @json_data = { "code" => code }
        render json: @json_data
      else
        return false
      end
    end

    # Generate new invoice from sale offer
    def cr_generate_invoice_from_offer
      client = params[:client]
      offer = params[:offer]
      invoice_date = params[:offer_date]  # YYYYMMDD
      invoice_no = nil
      bill_id = 0
      invoice = nil
      invoice_item = nil
      code = ''

      if offer != '0'
        sale_offer = SaleOffer.find(offer) rescue nil
        sale_offer_items = sale_offer.sale_offer_items rescue nil
        if !sale_offer.nil? && !sale_offer_items.nil?
          # Format offer_date
          invoice_date = (invoice_date[0..3] + '-' + invoice_date[4..5] + '-' + invoice_date[6..7]).to_date
          # Invoice No
          invoice_no = commercial_bill_next_no(sale_offer.project.company_id, sale_offer.project.office_id)
          if invoice_no != '$err'
            # Try to save new bill
            bill_id = bill_create_invoice_from_offer(sale_offer.project_id,
                                  sale_offer.client_id,
                                  invoice_date,
                                  sale_offer.payment_method_id)
            if bill_id > 0
              # Try to save new invoice
              invoice = Invoice.new
              invoice.bill_id = bill_id
              invoice.invoice_operation_id = InvoiceOperation::INVOICE
              invoice.invoice_status_id = InvoiceStatus::PENDING
              invoice.invoice_type_id = InvoiceType::COMMERCIAL
              invoice.biller_id = sale_offer.project.company_id
              invoice.invoice_no = invoice_no
              invoice.payment_method_id = sale_offer.payment_method_id
              invoice.invoice_date = invoice_date
              invoice.discount_pct = sale_offer.discount_pct
              invoice.charge_account_id = sale_offer.charge_account_id
              invoice.created_by = current_user.id if !current_user.nil?
              invoice.organization_id = sale_offer.organization_id
              invoice.sale_offer_id = sale_offer.id
              if invoice.save
                # Try to save new invoice items
                sale_offer_items.each do |i|
                  if i.unbilled_balance != 0 # Only items not billed yet
                    invoice_item = InvoiceItem.new
                    invoice_item.invoice_id = invoice.id
                    invoice_item.sale_offer_id = i.sale_offer_id
                    invoice_item.sale_offer_item_id = i.id
                    invoice_item.product_id = i.product_id
                    invoice_item.code = i.product.product_code
                    invoice_item.description = i.description
                    invoice_item.quantity = i.unbilled_balance
                    invoice_item.price = i.price
                    invoice_item.discount_pct = i.discount_pct
                    invoice_item.discount = i.discount
                    invoice_item.tax_type_id = i.tax_type_id
                    invoice_item.created_by = current_user.id if !current_user.nil?
                    if !invoice_item.save
                      # Can't save invoice item (exit)
                      code = '$write'
                      break
                    end   # !invoice_item.save?
                  end   # i.unbilled_balance != 0
                end   # do |i|
                # Update totals
                invoice.update_column(:totals, Invoice.find(invoice.id).total)
              else
                # Can't save invoice
                code = '$write'
              end   # invoice.save?
            else
              # Can't save bill
              code = '$write'
            end   # bill_id > 0
          else
            # Invalid invoice No
            code = '$err'
          end   # invoice_no != '$err'
        else
          # Sale offer or items not found
          code = '$err'
        end   # !sale_offer.nil? && !sale_offer_items.nil?
      else
        # Sale offer 0
        code = '$err'
      end   # offer != '0'
      if code == ''
        code = I18n.t("ag2_gest.commercial_billings.generate_invoice_ok", var: invoice.invoice_no.to_s)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Create associated Bill
    def bill_create_invoice_from_offer(_project, _client, _date, _payment_method)
      _r = 0
      _bill = Bill.new
      _bill.created_by = current_user.id if !current_user.nil?
      _bill.bill_no = bill_next_no(_project)
      bill_assign_invoice_from_offer(_bill, _project, _client, _date, _payment_method)
      if _bill.save
        _r = _bill.id
      end
      _r
    end

    def bill_assign_invoice_from_offer(_bill, _project, _client, _date, _payment_method)
      _c = Client.find(_client) rescue nil
      _p = Project.find(_project) rescue nil
      if !_c.nil? && !_p.nil?
        _bill.project_id = _project
        _bill.client_id = _client
        _bill.bill_date = _date
        _bill.invoice_status_id = InvoiceStatus::PENDING
        _bill.last_name = _c.last_name
        _bill.first_name = _c.first_name
        _bill.company = _c.company
        _bill.fiscal_id = _c.fiscal_id
        _bill.street_type_id = _c.street_type_id
        _bill.street_name = _c.street_name
        _bill.street_number = _c.street_number
        _bill.building = _c.building
        _bill.floor = _c.floor
        _bill.floor_office = _c.floor_office
        _bill.zipcode_id = _c.zipcode_id
        _bill.town_id = _c.town_id
        _bill.province_id = _c.province_id
        _bill.region_id = _c.region_id
        _bill.country_id = _c.country_id
        _bill.organization_id = _p.organization_id
        _bill.payment_method_id = _payment_method
      end
    end

    # Update service point code at view (generate_code_sp_btn)
    def serpoint_generate_no
      office = params[:id]
      # Builds code, if possible
      code = office == '$' ? '$err' : serpoint_next_no(office)
      @json_data = { "code" => code }
      render json: @json_data
    end

    def update_tariff_type_select_from_billing_concept
      billable_concept_ids = params[:billable_concept_ids]
      use = params[:use_ids]
      @billable_concept_ids = billable_concept_ids.split(",")

      @use = use.blank? ? '0' : Use.find(use)

      @grouped_options = @billable_concept_ids.inject({}) do |biller, bc|
        if @use == '0'
          _tariff_type_ids = BillableItem.find(bc).tariff_types.group(:tariff_type_id)
        else
          _tariff_type_ids = BillableItem.find(bc).tariff_types.where("use_id =? OR use_id IS NULL",@use.id).group(:tariff_type_id)
        end
        _tariff_type_ids.each do |ttt|
          @tariffs = ttt
          _label_biller = BillableItem.find(bc).to_label_biller
          (biller[_label_biller] ||= []) << {:name => @tariffs.to_label, :id => @tariffs.id}
        end
        biller
      end

      @tariff_type_dropdown =  @grouped_options

      # @tariff_type_ids = []
      # billable_concept_ids.each do |bc|
      #   #@tariff_type_ids += BillableConcept.find(bc).grouped_tariff_types
      #   @tariff_type_ids += BillableItem.find(bc).grouped_tariff_types
      # end
      # @tariff_type_dropdown = tariff_type_array(@tariff_type_ids)
      # Setup JSON

      @json_data = { "tariff_type_ids" => @grouped_options }
      render json: @grouped_options
    end

    def bill
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      @bill = @water_supply_contract.bill
    end

    def bill_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      @bill = @water_supply_contract.bailback_bill
    end

    # PDF Contracting Request
    def contracting_request_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      title = t("activerecord.models.contracting_request.one")
      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@contracting_request.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    def contracting_request_connection_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      title = t("activerecord.models.contracting_request.one")
      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@contracting_request.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    def contract_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      _tariff_type = []
      @water_supply_contract.contracted_tariffs.includes(tariff: {billable_item: :billable_concept}).order("billable_items.billable_concept_id").each do |tt|
          if !_tariff_type.include? tt.tariff.tariff_type.name
            _tariff_type = _tariff_type << tt.tariff.tariff_type.name
          end
      end
      @tariff_type = _tariff_type.join(", ")
      @tariff_type_billing_frequency = @water_supply_contract.contracted_tariffs.includes(tariff: {billable_item: :billable_concept}).order("billable_items.billable_concept_id").first
      title = t("activerecord.models.water_supply_contract.one")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@water_supply_contract.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    def sepa_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      @subscriber = @contracting_request.subscriber

      title = t("activerecord.attributes.water_supply_contract.pay_sepa_order_c")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@contracting_request.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
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
     @bill = @water_supply_contract.bill || @water_supply_contract.bailback_bill
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

    def complete_status
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

    # Create work order cancellation
    def ot_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      # current_user_id = current_user.id if !current_user.nil?
        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    master_order_id: @contracting_request.work_order_id,
                                    work_order_type_id: 29, #WorkOderType inspection Nestor - Baja Suministro Voluntaria G.A
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 151, # Nestor - Baja Suministro Retirar Contador
                                    work_order_area_id: 3, # Nestor - Gestion de abonados
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                    in_charge_id: 1,
                                    meter_id: @contracting_request.work_order.try(:meter_id),
                                    meter_code: @contracting_request.work_order.try(:meter_code),
                                    meter_model_id: @contracting_request.work_order.try(:meter_model_id),
                                    caliber_id: @contracting_request.work_order.try(:caliber_id),
                                    meter_owner_id: @contracting_request.work_order.try(:meter_owner_id),
                                    meter_location_id: @contracting_request.work_order.try(:meter_location_id)
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                  )
      if @work_order.save(:validate => false)
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          response_hash[:work_order] = @contracting_request.work_order
          response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first
          response_hash[:work_order_status_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first.work_order_status
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

    # Create work order cancellation
    def ot_connection_installation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_connection_contract = @contracting_request.water_connection_contract

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    master_order_id: @contracting_request.work_order_id,
                                    work_order_type_id: @contracting_request.water_connection_contract.water_connection_type_id == WaterConnectionType::SUM ? 37 : 38,
                                    work_order_status_id: 1, #WorkOderStatus
                                    work_order_labor_id: @contracting_request.water_connection_contract.water_connection_type_id == WaterConnectionType::SUM ? 163 : 164,
                                    work_order_area_id: 4, # TCA
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                    in_charge_id: 1,
                                    caliber_id: @contracting_request.water_connection_contract.try(:caliber_id)
                                  )

      if @work_order.save(:validate => false)
        @water_connection_contract.update_attributes(work_order_id: @work_order.id)
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          # response_hash[:work_order] = @contracting_request.work_order
          # response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_installation] = @contracting_request.water_connection_contract.work_order
          response_hash[:work_order_status_installation] = @contracting_request.water_connection_contract.work_order.work_order_status
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

    def ot_installation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      # current_user_id = current_user.id if !current_user.nil?

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    master_order_id: @contracting_request.work_order_id,
                                    work_order_type_id: 28, #WorkOderType inspection Nestor - Alta Suministro instalación contador G.A
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 150, # Nestor -  Instalación Contador Alta Nueva
                                    work_order_area_id: 3, # Nestor - Gestion de abonados
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                    in_charge_id: 1,
                                    meter_id: @contracting_request.work_order.try(:meter_id),
                                    meter_code: @contracting_request.work_order.try(:meter_code),
                                    meter_model_id: @contracting_request.work_order.try(:meter_model_id),
                                    caliber_id: @contracting_request.work_order.try(:caliber_id),
                                    meter_owner_id: @contracting_request.work_order.try(:meter_owner_id),
                                    meter_location_id: @contracting_request.work_order.try(:meter_location_id)
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                  )
      if @work_order.save(:validate => false)
        @water_supply_contract.update_attributes(work_order_id: @work_order.id)
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          response_hash[:work_order] = @contracting_request.work_order
          response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_installation] = @contracting_request.water_supply_contract.work_order
          response_hash[:work_order_status_installation] = @contracting_request.water_supply_contract.work_order.work_order_status
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


    # Create work order inspection
    def ot_connection_inspection
      @contracting_request = ContractingRequest.find(params[:id])
      # current_user_id = current_user.id if !current_user.nil?

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25,
                                    work_order_status_id: 1, #WorkOderStatus
                                    work_order_labor_id: 132,
                                    work_order_area_id: 4, # TCA
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
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

    def initial_inspection
      @contracting_request = ContractingRequest.find(params[:id])
      # current_user_id = current_user.id if !current_user.nil?

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25, #WorkOderType inspection Nestor - Inspección Instalación G.A
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 132, # Nestor - Inspección de Instalación
                                    work_order_area_id: 3, # Nestor - Gestion de abonados
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
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
    def connection_billing
      @contracting_request = ContractingRequest.find(params[:id])
      @water_connection_contract = @contracting_request.water_connection_contract

      @bill = @water_connection_contract.generate_bill

      if @bill
        @contracting_request.status_control("billing");
        if @contracting_request.save
          respond_to do |format|
            format.json { render json: response_hash }
            format.js {}
          end
        else
          respond_to do |format|
            format.json { render json: @water_connection_contract.errors.as_json, status: :unprocessable_entity }
          end
        end
      end
    end

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

    def inspection_billing_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @subscriber = @contracting_request.old_subscriber
      @reading = @subscriber.readings.where(billing_period_id: @contracting_request.old_subscriber.readings.last.billing_period_id, reading_type_id: [ReadingType::RETIRADA]).order(:reading_date).last
      if !@reading.billable?
        response_hash = { contracting_request: @contracting_request }
        response_hash[:reading] = !@reading.billable?
        redirect_to @contracting_request and return
         respond_to do |format|
          format.json { render json: response_hash }
          format.js {}
        end
      end

      @water_supply_contract = @contracting_request.water_supply_contract

      @billcontract = @water_supply_contract.generate_bill_cancellation
      @bill = @water_supply_contract.generate_bill_cancellation_service
      if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
        @billchange = @water_supply_contract.generate_bill
      end

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

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25, #WorkOderType inspection Nestor - Inspección Instalación G.A
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 132, # Nestor - Inspección de Instalación
                                    work_order_area_id: 3, # Nestor - Gestion de abonados
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                    in_charge_id: 1
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
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

    def initial_billing_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @subscriber = @contracting_request.old_subscriber
      @reading = @subscriber.readings.where(billing_period_id: @contracting_request.old_subscriber.readings.last.billing_period_id, reading_type_id: [ReadingType::RETIRADA]).order(:reading_date).last
      if !@reading.billable?
        response_hash = { contracting_request: @contracting_request }
        response_hash[:reading] = !@reading.billable?
        redirect_to @contracting_request and return
         respond_to do |format|
          format.json { render json: response_hash }
          format.js {}
        end
      end

        @work_order = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                    work_order_type_id: 25, #WorkOderType inspection Nestor - Inspección Instalación G.A
                                    work_order_status_id: 1, #WorkOderStatus initial Nestor
                                    work_order_labor_id: 132, # Nestor - Inspección de Instalación
                                    work_order_area_id: 3, # Nestor - Gestion de abonados
                                    project_id: @contracting_request.project_id,
                                    client_id: @contracting_request.client.id, # ¿¿??
                                    description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                    organization_id: @contracting_request.project.organization_id,
                                    charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                    in_charge_id: 1
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                  )
      if @work_order.save(:validate => false)
        @contracting_request.work_order = @work_order;
        @water_supply_contract = @contracting_request.water_supply_contract
        # current_user_id = current_user.id if !current_user.nil?
          @work_order_cancellation = WorkOrder.new(  order_no: wo_next_no(@contracting_request.project),
                                      master_order_id: @contracting_request.work_order_id,
                                      work_order_type_id: 29, #WorkOderType inspection Nestor - Baja Suministro Voluntaria G.A
                                      work_order_status_id: 1, #WorkOderStatus initial Nestor
                                      work_order_labor_id: 151, # Nestor - Baja Suministro Retirar Contador
                                      work_order_area_id: 3, # Nestor - Gestion de abonados
                                      project_id: @contracting_request.project_id,
                                      client_id: @contracting_request.client.id, # ¿¿??
                                      description: "#{t('activerecord.attributes.contracting_request.number_request')} " + @contracting_request.request_no,
                                      organization_id: @contracting_request.project.organization_id,
                                      charge_account_id: @contracting_request.project.try(:charge_accounts).try(:first).try(:id),
                                      in_charge_id: 1,
                                      meter_id: @contracting_request.work_order.try(:meter_id),
                                      meter_code: @contracting_request.work_order.try(:meter_code),
                                      meter_model_id: @contracting_request.work_order.try(:meter_model_id),
                                      caliber_id: @contracting_request.work_order.try(:caliber_id),
                                      meter_owner_id: @contracting_request.work_order.try(:meter_owner_id),
                                      meter_location_id: @contracting_request.work_order.try(:meter_location_id)
                                      # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                    )
        if @work_order_cancellation.save(:validate => false)
        end

        @billcontract = @water_supply_contract.generate_bill_cancellation
        @bill = @water_supply_contract.generate_bill_cancellation_service
        if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
          @billchange = @water_supply_contract.generate_bill
        end
        if @bill
          @contracting_request.status_control("billing");
          if @contracting_request.save
            response_hash = { contracting_request: @contracting_request }
            response_hash[:work_order] = @contracting_request.work_order
            response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
            response_hash[:work_order_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first
            response_hash[:work_order_status_cancellation] = WorkOrder.where(master_order_id: @contracting_request.work_order_id,work_order_type_id: 29).first.work_order_status
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
         _i = Invoice.find(invoice_item.invoice_id) if invoice_item
         _i.totals = _i.total if invoice_item
         _i.save if invoice_item
         invoice_item.update_attributes(item[1]) if invoice_item
      end
      respond_to do |format|
        format.json { render json: params["invoice_item"]}
      end
    end

    def billing_connection
      @contracting_request = ContractingRequest.find(params[:id])
        @contracting_request.status_control("complete");
        if @contracting_request.save
          @contracting_request.water_connection_contract.update_attributes(contract_date: Date.today) if @contracting_request.water_connection_contract
          response_hash = { contracting_request: @contracting_request }
          response_hash[:client_debt] = number_with_precision(@contracting_request.client.total_debt_unpaid, precision: 4, delimiter: I18n.locale == :es ? "." : ",") if @contracting_request.client
          response_hash[:bill] = @contracting_request.water_connection_contract.bill
          response_hash[:invoice] = @contracting_request.water_connection_contract.bill.invoices.first
          response_hash[:invoice_status] = @contracting_request.water_connection_contract.bill.invoices.first.invoice_status
          respond_to do |format|
            format.json { render json: response_hash }
          end
        else
          respond_to do |format|
            format.json { render :json => { :errors => @contracting_request.errors.as_json }, :status => 420 }
          end
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
          response_hash[:bill] = @contracting_request.water_supply_contract.bill
          response_hash[:invoice] = @contracting_request.water_supply_contract.bill.invoices.first
          response_hash[:invoice_status] = @contracting_request.water_supply_contract.bill.invoices.first.invoice_status
          response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_installation] = @contracting_request.water_supply_contract.work_order if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
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

    def billing_instalation_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      @reading = Reading.where(subscriber_id: @contracting_request.old_subscriber.id,reading_type_id: ReadingType::RETIRADA, billing_period_id: @contracting_request.old_subscriber.readings.last.billing_period_id, bill_id: nil)
        @contracting_request.status_control
        if @contracting_request.save
          # @reading.last.update_attributes(bill_id: @water_supply_contract.unsubscribe_bill_id)
          @contracting_request.water_supply_contract.bailback_bill.update_attributes(subscriber_id: @contracting_request.old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bailback_bill
          @contracting_request.water_supply_contract.unsubscribe_bill.update_attributes(subscriber_id: @contracting_request.old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill
          response_hash = { contracting_request: @contracting_request }
          response_hash[:bailback_bill] = @water_supply_contract.bailback_bill  if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bailback_bill
          response_hash[:unsubscribe_bill] = @water_supply_contract.unsubscribe_bill if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill
          response_hash[:bill] = @contracting_request.water_supply_contract.bill if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
          response_hash[:invoice] = @contracting_request.water_supply_contract.bill.invoices.first if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
          response_hash[:invoice_status] = @contracting_request.water_supply_contract.bill.invoices.first.invoice_status if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
          response_hash[:invoice_status_cancellation] = @contracting_request.water_supply_contract.unsubscribe_bill.invoices.first.invoice_status if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill
          response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_installation] = @contracting_request.water_supply_contract.work_order if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.work_order
          render json: response_hash
        else
          render :json => { :errors => @contracting_request.errors.as_json }, :status => 420
        end
      # else
      #   respond_to do |format|
      #     format.json { render :json => { :errors => @work_order.errors.as_json }, :status => 420 }
      #   end
      # end
    end

    def new_subscriber_cancellation
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      @subscriber = @contracting_request.old_subscriber
        @subscriber.update_attributes(ending_at: Date.today, active: false, meter_id: nil, service_point_id: nil)
        @subscriber.meter_details.last.update_attributes(withdrawal_date: Date.today ,
                                                                withdrawal_reading: @subscriber.readings.last.reading_index)
        if !@contracting_request.client.client_bank_accounts.blank? and @contracting_request.client.client_bank_accounts.last.subscriber_id == @subscriber.id and @contracting_request.client.client_bank_accounts.last.ending_at.nil?
          @contracting_request.client.client_bank_accounts.where(subscriber_id: @subscriber.id, ending_at: nil).last.update_attributes(ending_at: Date.today, updated_by: @contracting_request.created_by )
        end
        @contracting_request.status_control
        if @contracting_request.save
          @contracting_request.water_supply_contract.update_attributes(subscriber_id: @subscriber.id, contract_date: @subscriber.ending_at) if @contracting_request.water_supply_contract
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

    def update_bank_offices_from_bank
      bank = params[:id]
      if bank != '0'
        @bank = Bank.find(bank)
        @offices = @bank.blank? ? BankOffice.order(:bank_id, :code) : @bank.bank_offices.order(:bank_id, :code)
      else
        @offices = BankOffice.order(:bank_id, :code)
      end
      # Offers array
      @offices_dropdown = bank_offices_array(@offices)
      # Setup JSON
      @json_data = { "office" => @offices_dropdown }
      render json: @json_data
    end

    def update_tariff_schemes_from_use
      use = params[:id]
      @projects_ids = current_projects_ids

      if use != '0'
        @use = Use.find(use)
        @tariff_schemes = TariffScheme.belongs_to_projects(@projects_ids).where("use_id =? OR use_id IS NULL",@use.id).actives
      else
        @tariff_schemes = TariffScheme.belongs_to_projects(@projects_ids).actives
      end
      # Offers array
      @tariff_schemes_dropdown = tariff_schemes_array(@tariff_schemes)
      # Setup JSON
      @json_data = { "tariff_scheme" => @tariff_schemes_dropdown }
      render json: @json_data
    end

    # Update subscriber from service point
    def update_subscriber_from_service_point
      @service_point = ServicePoint.find(params[:id])
      @json_data = {  street_type_id: @service_point.street_directory.street_type_id,
                      street_directory_id: @service_point.street_directory_id,
                      street_number: @service_point.street_number,
                      building: @service_point.building,
                      floor: @service_point.floor,
                      floor_office: @service_point.floor_office,
                      zipcode_id: @service_point.zipcode_id,
                      town_id: @service_point.street_directory.town_id,
                      province_id: @service_point.street_directory.town.province_id,
                      region_id: @service_point.street_directory.town.province.region_id,
                      country_id: @service_point.street_directory.town.province.region.country_id,
                      center_id: @service_point.center_id
                    }
      respond_to do |format|
        format.html # update_subscriber_from_service_point.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { "subscriber" => "" }}
        end
    end

    # Update data connection from street_directory
    def update_connection_from_street_directory
      @street_directory = StreetDirectory.find(params[:id])
      @json_data = {  street_type_id: @street_directory.street_type_id,
                      street_name: @street_directory.street_name,
                      zipcode_id: @street_directory.zipcode_id,
                      town_id: @street_directory.town_id,
                      province_id: @street_directory.town.province_id,
                      region_id: @street_directory.town.province.region_id,
                      country_id: @street_directory.town.province.region.country_id,
                    }
      respond_to do |format|
        format.html
        format.json { render json: @json_data }
      end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { "subscriber" => "" }}
        end
    end

    # Update subscriber data if old subscriber exits
    def update_old_subscriber
      @subscriber = Subscriber.find(params[:id])
      @subscriber_debt = '0'
      service_points = []
      service_point = nil
      service_point_code = ''
      @street_directory = @subscriber.street_directory
      service_point = @subscriber.service_point rescue nil

      if !@subscriber.blank? and !@subscriber.invoice_current_debts.unpaid.blank?
        @subscriber_debt = number_with_precision(@subscriber.total_debt, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
      end

      if !service_point.nil?
        service_point_code = service_point.code
        search = ServicePoint.search do
          fulltext service_point_code
          with :office_id, current_offices_ids
          with :available_for_contract, true
          order_by :street_directory_id
          order_by :code
        end
        service_points = search.results
        if !service_points.empty?
          # Service points array
          search_array = service_points_array(service_points)
        end
      end
      # @contracting_request = @subscriber.try(:water_supply_contract).try(:contracting_request)
      @json_data = { "subscriber" => @subscriber,
                     "street_directory" => @street_directory,
                     "town" => @street_directory.town,
                     "province" => @street_directory.town.province,
                     "region" => @street_directory.town.province.region,
                     "country" => @street_directory.town.province.region.country,
                     "ServicePoint" => service_point_code,
                     "subscriber_debt" => @subscriber_debt,
                     "service_point" => search_array
                    }

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
      client = 0

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
          client_debt = '0'
          project_debt = '0'
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
          client = @entity.client
          street_directory = StreetDirectory.find_by_town_id_and_street_type_id_and_street_name(@entity.town_id,@entity.street_type_id,@entity.street_name.try(:upcase))
          service_point = ServicePoint.where(street_directory_id: street_directory.try(:id), street_number: @entity.street_number, building: @entity.building, floor: @entity.floor, floor_office: @entity.floor_office)

          client_debt = '0'
          project_debt = '0'
          project_d = ""
          if !client.blank? and !client.invoice_current_debts.unpaid.blank?
            # client_debt = number_with_precision(client.current_debt, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
            client_debt = number_with_precision(client.total_debt, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
            project_group = client.invoice_current_debts.unpaid.select('bills.project_id AS prj,sum(debt) AS debt').joins(invoice: :bill).group('bills.project_id')
            project_group.each do |pd|
              _pd_project = Project.find(pd.prj).name
              project_d = project_d  << _pd_project + " --> " + number_with_precision(pd.debt, precision: 4, delimiter: I18n.locale == :es ? "." : ",") + " // "
            end
            project_debt = project_d[0..-4]
          end
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
                      "street_directory_id" => street_directory.try(:id),
                      "service_point" => service_point.try(:first).try(:id),
                      "client_debt" => client_debt,
                      "project_debt" => project_debt
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

    #
    # Look for meter
    #
    def cr_find_meter
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
    def cr_find_subscriber
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

    #
    # Look for service point
    #
    def cr_find_service_point
      m = params[:service_point]
      alert = ""
      code = ''
      service_points = nil
      search_array = []

      if m != '$'
        search = ServicePoint.search do
          fulltext m
          with :office_id, current_offices_ids
          with :available_for_contract, true
          with :assigned_to_subscriber, false
          order_by :street_directory_id
          order_by :code
        end
        service_points = search.results

        if service_points.empty?
          # No service points found
          alert = I18n.t("activerecord.errors.models.contracting_request.service_point_not_found")
          code = '$err'
        else
          # Service points array
          search_array = service_points_array(service_points)
        end
      else
        # Invalid search string
        alert = I18n.t("activerecord.errors.models.contracting_request.invalid_search_string")
        code = '$err'
      end
      # Setup JSON
      @json_data = { "code" => code, "alert" => alert, "service_point" => search_array }
      render json: @json_data
    end

    #*** Charge modal dropdowns async ***
    def cr_load_form_dropdowns
      # OCO
      init_oco if !session[:organization]
      # _o = session[:office] != '0' ? session[:office].to_i : nil
      _o = current_offices_ids
      towns_by_office = current_offices.group(:town_id).pluck('offices.town_id')
      empty_array = []

      @json_data = { "subscribers" => empty_array, "service_points" => empty_array,
                    #  "subscribers" => subscribers_raw_array(_o), "service_points" => service_points_raw_array(_o),
                     "service_point_types" => service_point_types_array, "service_point_locations" => service_point_locations_array,
                     "service_point_purposes" => service_point_purposes_array, "centers" => centers_by_town_array(towns_by_office),
                     "street_types" => street_types_array, "street_directories_by_town" => street_directories_by_town_array(towns_by_office),
                    #  "street_directories" => street_directories_array(_o), "street_types" => street_types_array,
                     "towns_by_office" => towns_by_office_array(towns_by_office), "reading_routes" => reading_routes_raw_array(_o),
                     "towns" => towns_array, "provinces" => provinces_array, "zipcodes" => zipcodes_array,
                     "regions" => regions_array, "countries" => country_array,
                     "banks" => banks_array, "bank_offices" => bank_offices_array }
      render json: @json_data
    end

    def cr_load_show_dropdowns
      contracting_request = ContractingRequest.find(params[:crid])
      # OCO
      init_oco if !session[:organization]
      _o = session[:office] != '0' ? session[:office].to_i : nil
      towns_by_office = current_offices.group(:town_id).pluck('offices.town_id')

      @json_data = { "subscribers" => subscribers_raw_array(_o), "service_points" => service_points_raw_array(_o),
                     "service_point_types" => service_point_types_array, "service_point_locations" => service_point_locations_array,
                     "service_point_purposes" => service_point_purposes_array, "centers" => centers_array(_o),
                     "towns_by_office" => towns_by_office, "offices" => offices_array,
                     "street_directories" => street_directories_array(_o), "street_types" => street_types_array,
                     "towns" => towns_array, "provinces" => provinces_array, "zipcodes" => zipcodes_array,
                     "regions" => regions_array, "countries" => country_array,
                     "banks" => banks_array, "bank_offices" => bank_offices_array }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /requests
    # GET /requests.json
    def index
      manage_filter_state
      sort = params[:sort]
      direction = params[:direction]
      no = params[:No]
      client_info = params[:ClientInfo]
      project = params[:Project]
      request_status = params[:RequestStatus]
      request_type = params[:RequestType]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      @projects = projects_dropdown if @projects.nil?
      @request_statuses = request_statuses_dropdown if @request_statuses.nil?
      @request_types = request_types_dropdown if @request_types.nil?

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
        if !project.blank?
          with :project_id, project
        end
        if !request_status.blank?
          with :contracting_request_status_id, request_status
        end
        if !request_type.blank?
          with :contracting_request_type_id, request_type
        end
        if !from.blank?
          any_of do
            with(:request_date).greater_than(from)
            with :request_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:request_date).less_than(to)
            with :request_date, to
          end
        end
        if !sort.blank? and !direction.blank?
          order_by sort, direction
        else
          order_by :request_no, :desc
        end
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @contracting_requests = @search.results
      @reports = reports_array
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
      @water_connection_contract = @contracting_request.water_connection_contract || WaterConnectionContract.new
      @subscriber = @contracting_request.subscriber || Subscriber.new

      @work_order_retired = WorkOrder.where(client_id: @water_supply_contract.client_id, master_order_id: @contracting_request.work_order_id, work_order_type_id: 29, work_order_labor_id: 151, work_order_area_id: 3).first
      @tariff_types_availables = TariffType.availables_to_project(@contracting_request.project_id).order("billable_items.billable_concept_id")
      @billable_concept_availables = BillableItem.joins(:billable_concept,:regulation).where('(regulations.ending_at >= ? OR regulations.ending_at IS NULL) AND billable_concepts.billable_document = 1 AND billable_items.project_id = ?', Date.today,@contracting_request.project_id).order("billable_concepts.id")
      @calibers = Caliber.with_tariff.order(:caliber)
      @billing_periods = BillingPeriod.order("period DESC").includes(:billing_frequency).find_all_by_project_id(@projects_ids)
      _tariff_type = []
      @water_supply_contract.contracted_tariffs.includes(tariff: {billable_item: :billable_concept}).order("billable_items.billable_concept_id").each do |tt|
          if !_tariff_type.include? tt.tariff.tariff_type.name
            _tariff_type = _tariff_type << tt.tariff.tariff_type.name
          end
      end
      @tariff_type = _tariff_type.join(", ")

      tariff_type_select = []
      @water_supply_contract.contracted_tariffs.includes(tariff: {billable_item: :billable_concept}).order("billable_items.billable_concept_id").each do |tt|
          if !tariff_type_select.include? tt.tariff.tariff_type.id
            tariff_type_select = tariff_type_select << tt.tariff.tariff_type.id
          end
      end
      @tariff_type_select = tariff_type_select

      _billable_concept = []
      @water_supply_contract.contracted_tariffs.includes(tariff: {billable_item: :billable_concept}).order("billable_items.billable_concept_id").each do |tt|
          if !_billable_concept.include? tt.tariff.billable_item.id
            _billable_concept = _billable_concept << tt.tariff.billable_item.id
          end
      end
      if _billable_concept == []
        @billable_concept_availables.each do |tt|
            if !_billable_concept.include? tt.id
              _billable_concept = _billable_concept << tt.id
            end
        end
      end
      @billable_concept_select = _billable_concept

      # _tariff_type_ids = []
      # @billable_concept_select.each do |bc|
      #   #_tariff_type_ids += BillableConcept.find(bc).grouped_tariff_types
      #   _tariff_type_ids += BillableItem.find(bc).grouped_tariff_types
      # end
      # @tariff_type_dropdown = _tariff_type_ids

      @grouped_options = @billable_concept_select.inject({}) do |biller, bc|
        _tariff_type_ids = BillableItem.find(bc).grouped_tariff_types
        _tariff_type_ids.each do |ttt|
          @tariffs = ttt
          (biller[BillableItem.find(bc).to_label_biller] ||= []) << [@tariffs.to_label,@tariffs.id]
        end
        biller
      end
      @tariff_type_dropdown = @grouped_options

      # @meters_for_contract = available_meters_for_contract(@contracting_request)
      # @meters_for_subscriber = available_meters_for_subscriber(@contracting_request)

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

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request }
      end

    end

    # GET /contracting_requests/new_connection
    # GET /contracting_requests/new_connection.json
    def new_connection
      @breadcrumb = 'create'
      @contracting_request = ContractingRequest.new

      respond_to do |format|
        format.html # new_connection.html.erb
        format.json { render json: @contracting_request }
      end
    end

    # GET /contracting_requests/1/edit
    def edit
      @breadcrumb = 'update'
      @contracting_request = ContractingRequest.find(params[:id])
    end

    # GET /contracting_requests/1/edit_connection
    def edit_connection
      @breadcrumb = 'update'
      @contracting_request = ContractingRequest.find(params[:id])
    end

    # POST /requests
    # POST /requests.json
    def create
      @breadcrumb = 'create'
      @contracting_request = ContractingRequest.new(params[:contracting_request])
      @account_no = @contracting_request.account_no
      @contracting_request.account_no = @account_no unless @account_no.blank?
      @contracting_request.contracting_request_status_id = 1
      @contracting_request.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request.save
          @contracting_request.to_change_ownership if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
          @contracting_request.to_subrogation if @contracting_request.contracting_request_type_id == ContractingRequestType::SUBROGATION
          @contracting_request.to_cancellation if @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
          @contracting_request.to_add_concept if @contracting_request.contracting_request_type_id == ContractingRequestType::ADD_CONCEPT
          format.html { redirect_to @contracting_request, notice: t('activerecord.attributes.contracting_request.create')}
          format.json { render json: @contracting_request, status: :created, location: @contracting_request }
        else
          set_defaults_for_new_and_edit
          if @contracting_request.contracting_request_type_id == ContractingRequestType::CONNECTION
            format.html { render action: "new_connection" }
          else
            format.html { render action: "new" }
          end
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
          if @contracting_request.client.active_bank_account
            @contracting_request.client.active_bank_account.update_attributes(
                bank_account_class_id: BankAccountClass::SERVICIO,
                starting_at: @contracting_request.request_date,
                country_id: @contracting_request.country_id,
                iban_dc: @contracting_request.iban_dc,
                bank_id: @contracting_request.bank_id,
                bank_office_id: @contracting_request.bank_office_id,
                # ccc_dc: @contracting_request.account_no[0..1],
                account_no: @contracting_request.account_no,
                holder_fiscal_id: @contracting_request.client.fiscal_id,
                holder_name: @contracting_request.client.to_name)
          else
            ClientBankAccount.create(
                client_id: @contracting_request.client.id,
                bank_account_class_id: BankAccountClass::SERVICIO,
                starting_at: @contracting_request.request_date,
                country_id: @contracting_request.country_id,
                iban_dc: @contracting_request.iban_dc,
                bank_id: @contracting_request.bank_id,
                bank_office_id: @contracting_request.bank_office_id,
                # ccc_dc: @contracting_request.account_no[0..1],
                account_no: @contracting_request.account_no,
                holder_fiscal_id: @contracting_request.client.fiscal_id,
                holder_name: @contracting_request.client.to_name)
          end
          format.html { redirect_to @contracting_request,
                        notice: (crud_notice('updated', @contracting_request) + "#{undo_link(@contracting_request)}").html_safe }
          format.json { head :no_content }
        else
          set_defaults_for_new_and_edit
          format.html { render action: "edit" }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end

    def subrogation
      old_subcriber = Subscriber.find params[:subrogation][:subscriber]
      contracting_request = old_subcriber.water_supply_contract.contracting_request
      water_supply_contract = contracting_request.water_supply_contract
      new_entity = Entity.find params[:subrogation][:entity_id]
      ActiveRecord::Base.transaction do
        client = new_entity.client || Client.create!(
          active: true,
          building: params[:subrogation][:client_building],
          cellular: params[:subrogation][:client_cellular],
          client_code: Client.cl_next_code(contracting_request.project.organization.id),
          email: params[:subrogation][:client_email],
          fax: params[:subrogation][:client_fax],
          fiscal_id: new_entity.fiscal_id,
          floor: params[:subrogation][:client_floor],
          floor_office: params[:subrogation][:client_floor_office],
          first_name: new_entity.first_name,
          last_name: new_entity.last_name,
          company: new_entity.company,
          phone: params[:subrogation][:client_phone],
          street_name: params[:subrogation][:client_street_name],
          street_number: params[:subrogation][:client_street_number],
          organization_id: contracting_request.project.organization.id,
          entity_id: params[:subrogation][:entity_id],
          street_type_id: params[:subrogation][:client_street_type_id],
          zipcode_id: params[:subrogation][:client_zipcode_id],
          town_id: params[:subrogation][:client_town_id],
          province_id: params[:subrogation][:client_province_id],
          region_id: params[:subrogation][:client_region_id],
          country_id: params[:subrogation][:client_country_id],
          created_by: current_user.try(:id),
          payment_method_id: 1
        )

        contracting_request.update_attributes!(
          contracting_request_type_id: ContractingRequestType::SUBROGATION,
          entity_id: params[:subrogation][:entity_id],
          client_street_type_id: client.street_type_id,
          client_street_name: client.street_name,
          client_street_number: client.street_number,
          client_building: client.building,
          client_floor: client.floor,
          client_floor_office: client.floor_office,
          client_zipcode_id: client.zipcode_id,
          client_town_id: client.town_id,
          client_province_id: client.province_id,
          client_region_id: client.region_id,
          client_country_id: client.country_id,
          client_phone: client.phone,
          client_fax: client.fax,
          client_cellular: client.cellular,
          client_email: client.email
        )

        old_subcriber.update_attributes!(
          client_id: client.id,
          first_name: client.last_name,
          last_name: client.first_name,
          company: client.company,
          fiscal_id: client.fiscal_id,
          updated_by: current_user.id
        )

        water_supply_contract.update_attributes!(
          client_id: client.id
        )
      end
      redirect_to contracting_requests_path, notice: t("ag2_gest.contracting_requests.subrogation_notice")
    rescue ActiveRecord::RecordInvalid
       redirect_to contracting_requests_path, alert: t("ag2_gest.contracting_requests.subrogation_alert")
    end

    # DELETE /contracting_requests/1
    # DELETE /contracting_requests/1.json
    def destroy
      @contracting_request = ContractingRequest.find(params[:id])
      respond_to do |format|
        if @contracting_request.destroy
          format.html { redirect_to contracting_requests_url,
                      notice: (crud_notice('destroyed', @contracting_request) + "#{undo_link(@contracting_request)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to contracting_requests_url, alert: "#{@contracting_request.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end

     # contracting request report
    def contracting_request_report
      manage_filter_state

      no = params[:No]
      client_info = params[:ClientInfo]
      project = params[:Project]
      request_status = params[:RequestStatus]
      request_type = params[:RequestType]
      sort = params[:sort]
      from = params[:From]
      to = params[:To]

      projects = projects_dropdown
      request_statuses = request_statuses_dropdown
      request_types = request_types_dropdown

      # Arrays for search
      current_projects = projects.blank? ? [0] : current_projects_for_index(projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = ContractingRequest.search do
        if :contracting_request_status_id == 11
          return
        else
          with :contracting_request_status_id, (0..10)
          with :project_id, current_projects
          fulltext params[:search]
          if !client_info.blank?
            with :client_info, client_info
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
          if !from.blank?
            any_of do
              with(:request_date).greater_than(from)
              with :request_date, from
            end
          end
          if !to.blank?
            any_of do
              with(:request_date).less_than(to)
              with :request_date, to
            end
          end
          order_by :sort_no, :desc
          paginate :page => params[:page] || 1, :per_page => ContractingRequest.count
        end
      end
      @contracting_request_report = @search.results

      if !@contracting_request_report.blank?
        title = t("activerecord.models.contracting_request.few")
        @to = formatted_date(@contracting_request_report.first.created_at)
        @from = formatted_date(@contracting_request_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

     # contracting request complete report
    def contracting_request_complete_report
      manage_filter_state

      no = params[:No]
      client_info = params[:ClientInfo]
      project = params[:Project]
      request_status = params[:RequestStatus]
      request_type = params[:RequestType]
      sort = params[:sort]
      from = params[:From]
      to = params[:To]

      projects = projects_dropdown
      request_statuses = request_statuses_dropdown
      request_types = request_types_dropdown

      # Arrays for search
      current_projects = projects.blank? ? [0] : current_projects_for_index(projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = ContractingRequest.search do
        if [0..10].include? :contracting_request_status_id
          return
        else
          with :contracting_request_status_id, 11
          with :project_id, current_projects
          fulltext params[:search]
          if !client_info.blank?
            with :client_info, client_info
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
          if !from.blank?
            any_of do
              with(:request_date).greater_than(from)
              with :request_date, from
            end
          end
          if !to.blank?
            any_of do
              with(:request_date).less_than(to)
              with :request_date, to
            end
          end
          order_by :sort_no, :desc
          paginate :page => params[:page] || 1, :per_page => ContractingRequest.count
        end
      end
      @contracting_request_complete_report = @search.results

      if !@contracting_request_complete_report.blank?
        title = t("activerecord.models.contracting_request.few")
        @to = formatted_date(@contracting_request_complete_report.first.created_at)
        @from = formatted_date(@contracting_request_complete_report.last.created_at)
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

    # Filters
    def set_defaults_for_new_and_edit
      @projects = projects_dropdown
      @projects_ids = @projects.pluck(:id)
      @subscribers = []
      @service_points = []
      @service_point_types = []
      @service_point_locations = []
      @service_point_purposes = []
      @offices = []
      @centers = []
      @street_types = []
      @street_directories = []
      @towns = []
      @provinces = []
      @zipcodes = []
      @regions = []
      @countries = []
      @bank = []
      @bank_offices = []
      @reading_routes = []
    end

    def set_defaults_for_create_and_update
      @projects = projects_dropdown
      @projects_ids = projects_dropdown_ids
      @subscribers = []
      @service_points = []
      @service_point_types = []
      @service_point_locations = []
      @service_point_purposes = []
      @offices = current_offices.group(:town_id).pluck('offices.town_id')
      @centers = session[:office] != '0' ? Center.where(town_id: Office.find(session[:office].to_i).town_id).by_town : Center.by_town
      @street_types = StreetType.by_code
      @street_directories = []
      @towns = towns_dropdown
      @provinces = provinces_dropdown
      @zipcodes = zipcodes_dropdown
      @regions = Region.order(:name)
      @countries = Country.order(:name)
      @bank = banks_dropdown
      @bank_offices = bank_offices_dropdown
    end

    def set_defaults_for_show
      @projects = projects_dropdown
      @projects_ids = projects_dropdown_ids
      @tariff_types_availables = []
      @billable_concept_availables = []
      @calibers = []
      @billing_periods = []
    end

    # Dropdowns
    def subscribers_dropdown
      Subscriber.dropdown
    end

    def service_points_dropdown
      ServicePoint.dropdown
    end

    def service_point_types_dropdown
      ServicePointType.by_name
    end

    def service_point_locations_dropdown
      ServicePointLocation.by_name
    end

    def service_point_purposes_dropdown
      ServicePointPurpose.by_name
    end

    def centers_dropdown
      Center.dropdown
    end

    def street_directories_dropdown
      StreetDirectory.dropdown
    end

    def towns_dropdown
      Town.dropdown
    end

    def provinces_dropdown
      Province.order('provinces.name').joins(:region)
              .select("provinces.id, CONCAT(provinces.name, ' (', regions.name, ')') to_label_")
    end

    def zipcodes_dropdown
      Zipcode.order(:zipcode).joins(:town, :province) \
             .select("zipcodes.id, CONCAT(zipcodes.zipcode, ' - ', towns.name, ' (', provinces.name, ')') to_label_")
    end

    def regions_dropdown
      Region.order('regions.name').joins(:country) \
            .select("regions.id, CONCAT(regions.name, ' (', countries.name, ')') to_label_")
    end

    def countries_dropdown
      Country.order(:name) \
             .select("id, CONCAT(code, ' ', name) to_label_")
    end

    def street_types_dropdown
      StreetType.order(:street_type_code) \
                .select("id, CONCAT(street_type_code, ' (', street_type_description, ')') to_label_")
    end

    def banks_dropdown
      Bank.order(:code) \
          .select("id, CONCAT(code, ' ', name) to_label_")
    end

    def bank_offices_dropdown
      BankOffice.order('bank_offices.bank_id, bank_offices.code').joins(:bank)
                .select("bank_offices.id, CONCAT(bank_offices.code, ' ', bank_offices.name, ' (', banks.code, ')') to_label_")
    end

    def bank_account_classes_dropdown
      BankAccountClass.order(:name) \
                      .select("id, name to_label_")
    end

    def available_meters_for_contract(_request)
      if session[:office] != '0'
        Meter.from_office(session[:office]).availables(_request.try(:old_subscriber).try(:meter_id))
      else
        Meter.availables(_request.try(:old_subscriber).try(:meter_id))
      end
    end

    def available_meters_for_subscriber(_request)
      if _request.water_supply_contract.blank? || _request.water_supply_contract.caliber_id.blank?
        available_meters_for_contract(_request)
      else
        if session[:office] != '0'
          Meter.from_office(session[:office]).availables_by_caliber(_request.try(:old_subscriber).try(:meter_id), _request.water_supply_contract.caliber_id)
        else
          Meter.availables_by_caliber(_request.try(:old_subscriber).try(:meter_id), _request.water_supply_contract.caliber_id)
        end
      end
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def projects_dropdown
      if session[:office] != '0'
        Project.where(office_id: session[:office].to_i).ser_or_tca_order_type
      elsif session[:company] != '0'
        Project.where(company_id: session[:company].to_i).ser_or_tca_order_type
      else
        session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).ser_or_tca_order_type : Project.ser_or_tca_order_type
      end
    end

    def projects_dropdown_ids
      projects_dropdown.pluck(:id)
    end

    def projects_connection_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i) : Project.all
      end
    end

    def projects_connection_dropdown_ids
      projects_connection_dropdown.pluck(:id)
    end

    def request_statuses_dropdown
      ContractingRequestStatus.order(:name)
    end

    def request_types_dropdown
      ContractingRequestType.order(:description)
    end

    def work_orders_dropdown
      WorkOrder.order(:order_no)
    end

    # Dropdown arrays
    def reports_array()
      _array = []
      _array = _array << t("ag2_gest.contracting_requests.report.contracting_request_report")
      _array = _array << t("ag2_gest.contracting_requests.report.contracting_request_complete_report")
      _array
    end

    def tariff_type_array(_tariff_type)
      _array = []
      _tariff_type.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def tariff_schemes_array(_tariff_schemes)
      _array = []
      _tariff_schemes.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def subscribers_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.code_full_name_or_company_address]
      end
      _array
    end

    def subscribers_raw_array(_o=nil)
      _s = Subscriber.dropdown(_o)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def service_points_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label_and_assigned]
      end
      _array
    end

    def service_points_raw_array(_o=nil)
      _s = ServicePoint.dropdown(_o)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def reading_routes_raw_array(_o=nil)
      _s = ReadingRoute.dropdown(_o)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def service_point_types_array
      _s = service_point_types_dropdown
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.name]
      end
      _array
    end

    def service_point_locations_array
      _s = service_point_locations_dropdown
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.name]
      end
      _array
    end

    def service_point_purposes_array
      _s = service_point_purposes_dropdown
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.name]
      end
      _array
    end

    def towns_by_office_array(_t)
      _towns = Town.dropdown(_t)
      _array = []
      _towns.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def towns_array
      _towns = towns_dropdown
      _array = []
      _towns.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def provinces_array
      _provinces = provinces_dropdown
      _array = []
      _provinces.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def zipcodes_array
      _zipcodes = zipcodes_dropdown
      _array = []
      _zipcodes.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def regions_array
      _regions = regions_dropdown
      _array = []
      _regions.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def country_array
      _country = countries_dropdown
      _array = []
      _country.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def street_types_array
      _street_types = street_types_dropdown
      _array = []
      _street_types.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def banks_array
      _banks = banks_dropdown
      _array = []
      _banks.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def bank_offices_array
      _bank_offices = bank_offices_dropdown
      _array = []
      _bank_offices.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def bank_account_classes_array
      _bac = bank_account_classes_dropdown
      _array = []
      _bac.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def centers_by_town_array(_t)
      _s = Center.dropdown(_t)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def centers_by_office_array(_o=nil)
      _s = _o.nil? ? Center.dropdown : Center.dropdown(Office.find(_o).town_id)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def street_directories_array(_o=nil)
      _s = _o.nil? ? StreetDirectory.dropdown : StreetDirectory.dropdown(Office.find(_o).town_id)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def street_directories_by_town_array(_t)
      _s = StreetDirectory.dropdown(_t)
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def offices_array
      _s = current_offices
      _array = []
      _s.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    # Index sort by column name
    def sort_column
      ContractingRequest.column_names.include?(params[:sort]) ? params[:sort] : "request_no"
    end

    # Filter params status
    def manage_filter_state
      # search
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
      # client
      if params[:ClientInfo]
        session[:ClientInfo] = params[:ClientInfo]
      elsif session[:ClientInfo]
        params[:ClientInfo] = session[:ClientInfo]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # RequestType
      if params[:RequestType]
        session[:RequestType] = params[:RequestType]
      elsif session[:RequestType]
        params[:RequestType] = session[:RequestType]
      end
      # RequestStatus
      if params[:RequestStatus]
        session[:RequestStatus] = params[:RequestStatus]
      elsif session[:RequestStatus]
        params[:RequestStatus] = session[:RequestStatus]
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
  end
end
