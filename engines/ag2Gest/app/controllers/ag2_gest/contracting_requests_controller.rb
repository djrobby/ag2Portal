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
                                                :update_subscriber_from_service_point,
                                                :update_bank_offices_from_bank,
                                                :validate_fiscal_id_textfield,
                                                :validate_r_fiscal_id_textfield,
                                                :et_validate_fiscal_id_textfield,
                                                :cr_generate_no,
                                                :show_test,
                                                :next_status,
                                                :initial_inspection,
                                                :ot_cancellation,
                                                :ot_installation,
                                                :initial_billing,
                                                :initial_billing_cancellation,
                                                :inspection_billing,
                                                :inspection_billing_cancellation,
                                                :billing_instalation,
                                                :billing_instalation_cancellation,
                                                :new_subscriber_cancellation,
                                                :instalation_subscriber,
                                                :contracting_request_pdf,
                                                :bill,
                                                :update_bill,
                                                :biller_pdf,
                                                :get_caliber,
                                                :update_old_subscriber,
                                                :dn_update_from_invoice,
                                                :initial_complete,
                                                :billing_complete,
                                                :cr_find_meter,
                                                :cr_find_subscriber,
                                                :cr_find_service_point ]
    # Helper methods for
    helper_method :sort_column
    # => search available meters
    helper_method :available_meters_for_contract
    helper_method :available_meters_for_subscriber

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

    def contract_pdf
      @contracting_request = ContractingRequest.find(params[:id])
      @water_supply_contract = @contracting_request.water_supply_contract
      title = t("activerecord.models.water_supply_contract.one")
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
                                    in_charge_id: 1
                                    # started_at:, completed_at:, closed_at:, charge_account_id: 1,area_id:, store_id:, created_by: current_user_id, updated_by: current_user_id, remarks:,petitioner:, master_order_id:, reported_at:, approved_at:, certified_at:, posted_at:, location:, pub_record:,
                                  )
      if @work_order.save(:validate => false)
        @water_supply_contract.update_attributes(work_order_id: @work_order.id)
        if @contracting_request.save
          response_hash = { contracting_request: @contracting_request }
          response_hash[:work_order] = @contracting_request.work_order
          response_hash[:work_order_status] = @contracting_request.work_order.work_order_status
          response_hash[:work_order_cancellation] = @contracting_request.water_supply_contract.work_order
          response_hash[:work_order_status_cancellation] = @contracting_request.water_supply_contract.work_order.work_order_status
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
                                    in_charge_id: 1
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

        @billcontract = @water_supply_contract.generate_bill_cancellation
        @bill = @water_supply_contract.generate_bill_cancellation_service
        if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
          @billchange = @water_supply_contract.generate_bill
        end
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
          response_hash[:unsubscribe_bill] = @water_supply_contract.unsubscribe_bill
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

    # Update subscriber data if old subscriber exits
    def update_old_subscriber
      @subscriber = Subscriber.find(params[:id])
      service_points = []
      service_point = nil
      service_point_code = ''
      @street_directory = @subscriber.street_directory
      service_point = @subscriber.service_point rescue nil
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
        st_directory = StreetDirectory.find_by_street_type_id_and_street_name(1,"La Luz")
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
          street_directory = StreetDirectory.find_by_town_id_and_street_type_id_and_street_name(@entity.town_id,@entity.street_type_id,@entity.street_name.try(:upcase))
          service_point = ServicePoint.where( street_directory_id: street_directory.try(:id),street_number: @entity.street_number ,building: @entity.building ,floor: @entity.floor ,floor_office: @entity.floor_office)
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
                      "service_point" => service_point.try(:first).try(:id)
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
          # with :assigned_to_subscriber, false
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

    #
    # Default Methods
    #
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
      from = params[:From]
      to = params[:To]

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
      @work_order_retired = WorkOrder.where(client_id: @water_supply_contract.client_id, master_order_id: @contracting_request.work_order_id, work_order_type_id: 29, work_order_labor_id: 151, work_order_area_id: 3)
      @subscriber = @contracting_request.try(:subscriber) || Subscriber.new
      @projects = current_projects
      @projects_ids = current_projects_ids
      @tariff_types_availables = TariffType.availables_to_project(@contracting_request.project_id)
      @calibers = Caliber.with_tariff.order(:caliber)
      @billing_periods = BillingPeriod.order("period DESC").includes(:billing_frequency).find_all_by_project_id(@projects_ids)
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
      @projects = current_projects
      @projects_ids = current_projects_ids
      # _subscribers = Subscriber.where(office_id: current_offices_ids)
      # @subscribers = Subscriber.where(office_id: current_offices_ids).availables if !_subscribers.empty?
      @subscribers = []
      # @service_points = ServicePoint.where(office_id: current_offices_ids, available_for_contract: true).select{|s| s.subscribers.empty?}
      @service_points = []
      @offices = current_offices.group(:town_id).pluck(:town_id)
      @street_types = StreetType.order(:street_type_code)
      @towns = Town.order(:name)
      @provinces = Province.order(:name)
      @regions = Region.order(:name)
      @countries = Country.order(:name)
      @zipcodes = Zipcode.order(:zipcode)
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
      @service_points = ServicePoint.where(office_id: current_offices_ids, available_for_contract: true).select{|s| s.subscribers.empty?}
      @offices = current_offices
    end

    # POST /requests
    # POST /requests.json
    def create
      @breadcrumb = 'create'
      # @projects = current_projects
      # @projects_ids = current_projects_ids
      # _subscribers = Subscriber.where(office_id: current_offices_ids)
      # @subscribers = Subscriber.where(office_id: current_offices_ids).availables if !_subscribers.empty?
      # @service_points = ServicePoint.where(office_id: current_offices_ids, available_for_contract: true).select{|s| s.subscribers.empty?}
      # @offices = current_offices
      @contracting_request = ContractingRequest.new(params[:contracting_request])
      @account_no = @contracting_request.account_no
      @contracting_request.ccc_dc = @account_no[0..1] unless @account_no.blank?
      @contracting_request.account_no = @account_no[2..11] unless @account_no.blank?
      @contracting_request.contracting_request_status_id = 1
      @contracting_request.created_by = current_user.id if !current_user.nil?
      respond_to do |format|
        if @contracting_request.save
          @contracting_request.to_change_ownership if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP
          @contracting_request.to_subrogation if @contracting_request.contracting_request_type_id == ContractingRequestType::SUBROGATION
          @contracting_request.to_cancellation if @contracting_request.contracting_request_type_id == ContractingRequestType::CANCELLATION
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
          if @contracting_request.client.active_bank_account
            @contracting_request.client.active_bank_account.update_attributes(
                bank_account_class_id: BankAccountClass::SERVICIO,
                starting_at: @contracting_request.request_date,
                country_id: @contracting_request.country_id,
                iban_dc: @contracting_request.iban_dc,
                bank_id: @contracting_request.bank_id,
                bank_office_id: @contracting_request.bank_office_id,
                ccc_dc: @contracting_request.account_no[0..1],
                account_no: @contracting_request.account_no[2..11],
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
                ccc_dc: @contracting_request.account_no[0..1],
                account_no: @contracting_request.account_no[2..11],
                holder_fiscal_id: @contracting_request.client.fiscal_id,
                holder_name: @contracting_request.client.to_name)
          end
          format.html { redirect_to @contracting_request,
                        notice: (crud_notice('updated', @contracting_request) + "#{undo_link(@contracting_request)}").html_safe }
          format.json { head :no_content }
        else
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
        if :contracting_request_status_id == 0..10
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

    def reports_array()
      _array = []
      _array = _array << t("ag2_gest.contracting_requests.report.contracting_request_report")
      _array = _array << t("ag2_gest.contracting_requests.report.contracting_request_complete_report")
      _array
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def subscribers_array(_m)
      _array = []
      _m.each do |i|
        _array = _array << [i.id, i.to_label]
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
      ContractingRequestStatus.order(:name)
    end

    def request_types_dropdown
      ContractingRequestType.order(:description)
    end

    def work_orders_dropdown
      WorkOrder.order(:order_no)
    end

    def sort_column
      ContractingRequest.column_names.include?(params[:sort]) ? params[:sort] : "request_no"
    end

    def bank_offices_array(_offices)
      _array = []
      _offices.each do |i|
        _array = _array << [i.id, i.code, i.name, "(" + i.bank.code + ")"]
      end
      _array
    end

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
