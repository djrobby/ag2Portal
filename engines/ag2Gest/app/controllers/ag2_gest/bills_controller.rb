require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'
require_relative 'thinreports-with-text-rotation'

module Ag2Gest
  class BillsController < ApplicationController
    @@subscribers = nil
    @@period = nil
    @@readings = nil

    # def void
    #   @subscriber = Subscriber.find params[:id]
    #   @bill = Bill.find params[:bill_id]
    #   void_bill(bill)
    #   redirect_to subscriber_path(@subscriber, bill: @bill.id)
    # end

    # def rebilling
    #   @subscriber = Subscriber.find params[:id]
    #   @bill = Bill.find params[:bill_id]
    #   void_bill(bill)
    #   @reading = @subscriber.readings.find_by_billing_period_id(params[:bills][:billing_period_id])
    #   @bill = @reading.generate_pre_bill
    #   redirect_to subscriber_path(@subscriber, bill: @bill.id)
    # end

    def bill_supply_pdf
      @bill = Bill.find(params[:id])

      if !@bill.water_supply_contract.nil?
        @water_supply_contract = @bill.water_supply_contract
        @contracting_request = @water_supply_contract.contracting_request
      else
        @reading = @bill.reading
        @subscriber = @bill.subscriber
      end

      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "SCR-#{@bill.id}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    # add mj
    # PDF Biller
    def biller_contract_pdf
      # Search invoice & items
      @biller_printer = Bill.find(params[:id])
      @water_supply_contract = !@biller_printer.water_supply_contract.blank? ? @biller_printer.water_supply_contract : @biller_printer.bailback_water_supply_contract
      @water_connection_contract = @biller_printer.water_connection_contract 
      
      @contracting_request = !@water_supply_contract.blank? ? @water_supply_contract.contracting_request : @water_connection_contract.contracting_request
      @invoice = @biller_printer.invoices.first
      @items = @invoice.invoice_items.order('id')

      title = t("activerecord.models.invoice.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@invoice.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    def biller_connection_contract_pdf
      # Search invoice & items
      @biller_printer = Bill.find(params[:id])
      @water_supply_contract = !@biller_printer.water_supply_contract.blank? ? @biller_printer.water_supply_contract : @biller_printer.bailback_water_supply_contract
      @water_connection_contract = @biller_printer.water_connection_contract 
      
      @contracting_request = !@water_supply_contract.blank? ? @water_supply_contract.contracting_request : @water_connection_contract.contracting_request
      @invoice = @biller_printer.invoices.first
      @items = @invoice.invoice_items.order('id')

      title = t("activerecord.models.invoice.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@invoice.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    def biller_pdf
      @biller_printer = Bill.find(params[:id])
      title = t("activerecord.models.bill.few")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@biller_printer.full_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end
    # add mj

    ### DO NOT USE: It's a mess! ###
    # def do_not_use_bills_with_this_attributes(operation_id=1)
    #   Bill.where(reading_2_id: reading_ids_subscriber_period).blank? and Bill.select{|b| b.bill_operation == InvoiceOperation::INVOICE and b.bill_period == pre_bill.reading_2.billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == pre_bill.subscriber_id}.blank?
    # end

    # Returns bills with this pre_bill data
    def bills_with_this_attributes(pre_bill)
      Bill.joins(:invoices).where(invoices: {invoice_operation_id: InvoiceOperation::INVOICE, billing_period_id: pre_bill.billing_period_id, invoice_type_id: InvoiceType::WATER}, subscriber_id: pre_bill.subscriber_id)
    end

    # There is active Bill for the PreBill reading?
    def pre_bill_reading_not_billed?(pre_bill)
      pre_bill.reading_2.bill_id.blank?
    end

    # This PreBill can be confirmed and create new Bill?
    def pre_bill_can_be_confirmed?(pre_bill)
      pre_bill_reading_not_billed?(pre_bill) && bills_with_this_attributes(pre_bill).count <= 0
    end

    #
    # Bulk billing (confirm prebilling)
    #
    # def confirm
    #   @pre_bills = PreBill.where(pre_group_no: params[:pre_bill][:ids], bill_id: nil)
    #   pre_bills_count = @pre_bills.count
    #   by_user = current_user.nil? ? nil : current_user.id
    #   payday_limit = params[:pre_bill][:payday_limit]
    #   invoice_date = params[:pre_bill][:invoice_date]
    #   final_bills = []
    #   @pre_bills.each do |pre_bill|
    #     # Begin: What the hell is this???!!!
    #     # reading_ids_subscriber_period = pre_bill.subscriber.readings.where(billing_period_id: pre_bill.reading_2.billing_period_id).map(&:id)
    #     # if Bill.where(reading_2_id: reading_ids_subscriber_period).blank? and Bill.select{|b| b.bill_operation == InvoiceOperation::INVOICE and b.bill_period == pre_bill.reading_2.billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == pre_bill.subscriber_id}.blank?
    #     # End
    #     #
    #     # If the next 'if' is not enough, revert to this one:
    #     # if pre_bill_can_be_confirmed?(pre_bill)
    #     if pre_bill_reading_not_billed?(pre_bill)
    #       @bill = Bill.create!( bill_no: bill_next_no(pre_bill.project),
    #         project_id: pre_bill.project_id,
    #         # project_id: pre_bill.reading.project_id,
    #         invoice_status_id: InvoiceStatus::PENDING,
    #         bill_date: invoice_date,
    #         subscriber_id: pre_bill.subscriber_id,
    #         client_id: pre_bill.client_id,
    #         last_name: pre_bill.last_name,
    #         first_name: pre_bill.first_name,
    #         company: pre_bill.company,
    #         fiscal_id: pre_bill.fiscal_id,
    #         street_type_id: pre_bill.street_type_id,
    #         street_name: pre_bill.street_name,
    #         street_number: pre_bill.street_number,
    #         building: pre_bill.building,
    #         floor: pre_bill.floor,
    #         floor_office: pre_bill.floor_office,
    #         zipcode_id: pre_bill.zipcode_id,
    #         town_id: pre_bill.town_id,
    #         province_id: pre_bill.province_id,
    #         region_id: pre_bill.region_id,
    #         country_id: pre_bill.country_id,
    #         created_by: by_user,
    #         reading_1_id: pre_bill.reading_1_id,
    #         reading_2_id: pre_bill.reading_2_id,
    #         organization_id: pre_bill.project.organization_id )
    #       pre_bill.pre_invoices.map do |pre_invoice|
    #         @invoice = Invoice.create!( invoice_no: invoice_next_no(pre_bill.project.company_id, pre_bill.project.office_id),
    #           bill_id: @bill.id,
    #           invoice_status_id: InvoiceStatus::PENDING,
    #           invoice_type_id: InvoiceType::WATER,
    #           invoice_date: invoice_date,
    #           tariff_scheme_id: pre_invoice.tariff_scheme_id,
    #           payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
    #           invoice_operation_id: InvoiceOperation::INVOICE,
    #           billing_period_id: pre_invoice.billing_period_id,
    #           consumption: pre_invoice.consumption,
    #           consumption_real: pre_invoice.consumption_real,
    #           consumption_estimated: pre_invoice.consumption_estimated,
    #           consumption_other: pre_invoice.consumption_other,
    #           biller_id: pre_invoice.biller_id,
    #           discount_pct: pre_invoice.discount_pct,
    #           exemption: pre_invoice.exemption,
    #           charge_account_id: pre_invoice.charge_account_id,
    #           created_by: by_user,
    #           reading_1_date: pre_invoice.reading_1_date,
    #           reading_2_date: pre_invoice.reading_2_date,
    #           reading_1_index: pre_invoice.reading_1_index,
    #           reading_2_index: pre_invoice.reading_2_index,
    #           organization_id: pre_bill.project.organization_id )
    #         pre_invoice.pre_invoice_items.map do |pre_invoice_item|
    #           InvoiceItem.create!( invoice_id: @invoice.id,
    #             code: pre_invoice_item.code,
    #             description: pre_invoice_item.description,
    #             tariff_id: pre_invoice_item.tariff_id,
    #             price:  pre_invoice_item.price,
    #             quantity: pre_invoice_item.quantity,
    #             tax_type_id: pre_invoice_item.tax_type_id,
    #             discount_pct: pre_invoice_item.discount_pct,
    #             discount: pre_invoice_item.discount,
    #             product_id: pre_invoice_item.product_id,
    #             subcode: pre_invoice_item.subcode,
    #             measure_id: pre_invoice_item.measure_id,
    #             created_by: by_user
    #           )
    #         end
    #         @bill.reading_2.update_attributes(bill_id: @bill.id)
    #         pre_bill.update_attributes(bill_id: @bill.id,confirmation_date: params[:pre_bill][:confirmation_date])
    #         # add mj
    #         pre_invoice.update_attributes(invoice_id: @invoice.id,confirmation_date: params[:pre_bill][:confirmation_date])
    #
    #         # Save totals in generated invoice
    #         _i = Invoice.find(@invoice.id)
    #         _i.totals = _i.total
    #         _i.save
    #       end
    #       # add mj
    #       final_bills << @bill
    #     end
    #   end
    #   # params for modal
    #   redirect_to pre_index_bills_path( modal: "true",
    #                                     pre_bill_no: params[:pre_bill][:ids],
    #                                     total: final_bills.sum(&:total),
    #                                     pre_bills: pre_bills_count,
    #                                     count: final_bills.count,
    #                                     consumptions: final_bills.map{|b| b.reading_2}.sum(&:consumption),
    #                                     invoice_date: invoice_date,
    #                                     payday_limit: payday_limit,
    #                                     first_bill: (final_bills.first.full_no unless final_bills.blank?),
    #                                     last_bill: (final_bills.last.full_no unless final_bills.blank?)
    #                                   )
    # end

    def get_subscribers
      _reading_routes = params[:bill][:reading_routes].reject(&:empty?)
      reading_routes = _reading_routes.blank? ? ReadingRoute.pluck(:id) : _reading_routes
      _offices = current_offices_ids
      offices = _offices.blank? ? Office.pluck(:id) : _offices
      _centers = params[:bill][:centers].reject(&:empty?)
      centers = _centers.blank? ? Center.pluck(:id) : _centers
      @@period = params[:bill][:period]
      _uses = params[:bill][:use].reject(&:empty?)
      uses = _uses.blank? ? Use.pluck(:id) : _uses
      from_subscriber = params[:From]
      to_subscriber = params[:To]

      # Select subscribers properly
      # With readings (preferable)
      subscribers_with_readings(uses, reading_routes, offices, centers, from_subscriber, to_subscriber)
      # Without readings (faster)
      # subscribers_only(uses, reading_routes, offices, centers)
      # Extract only needed colums (street_directories & street_types were previously cached)
      subscribers_label = @@subscribers.map{|s| [s.id, "#{s.to_label} - #{s.address_1} - #{s.meter_code}"]}
      # Returns JSON hash
      response_hash = { subscribers: subscribers_label}

      ### SubscriberFiliation is too slow ###
      # # Select subscribers properly (caching street_directories & street_types), extracting only needed colums!
      # @@subscribers = SubscriberFiliation.joins(subscriber: :readings).where('subscribers.active=TRUE AND (subscriber_filiations.use_id IN (?) OR subscriber_filiations.use_id IS NULL) AND subscriber_filiations.reading_route_id IN (?) AND subscriber_filiations.office_id IN (?) AND subscriber_filiations.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?)', uses, reading_routes, offices, centers, @@period, ReadingType.billable).includes(street_directory: :street_type).select('subscriber_filiations.subscriber_id,everything')
      # # Returns JSON hash
      # response_hash = { subscribers: @@subscribers }

      render json: response_hash
    end

    def subscribers_with_readings(uses, reading_routes, offices, centers, from_subscriber, to_subscriber)
      if (!from_subscriber.nil? && from_subscriber != "") && (!to_subscriber.nil? && to_subscriber != "")
        @@subscribers = Subscriber.select('subscribers.id, subscriber_code, last_name, first_name, company, street_directory_id, street_number, building, floor, floor_office, subscribers.meter_id') \
                                .joins(:readings) \
                                .where('subscribers.active=TRUE AND (subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?) AND subscribers.subscriber_code BETWEEN ? AND ?', uses, reading_routes, offices, centers, @@period, ReadingType.billable,from_subscriber,to_subscriber) \
                                .group('subscribers.id') \
                                .includes(:meter, street_directory: :street_type)
      elsif !from_subscriber.nil? && from_subscriber != ""
        @@subscribers = Subscriber.select('subscribers.id, subscriber_code, last_name, first_name, company, street_directory_id, street_number, building, floor, floor_office, subscribers.meter_id') \
                                .joins(:readings) \
                                .where('subscribers.active=TRUE AND (subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?) AND subscribers.subscriber_code >= ?', uses, reading_routes, offices, centers, @@period, ReadingType.billable,from_subscriber) \
                                .group('subscribers.id') \
                                .includes(:meter, street_directory: :street_type)
      elsif !to_subscriber.nil? && to_subscriber != ""
        @@subscribers = Subscriber.select('subscribers.id, subscriber_code, last_name, first_name, company, street_directory_id, street_number, building, floor, floor_office, subscribers.meter_id') \
                                .joins(:readings) \
                                .where('subscribers.active=TRUE AND (subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?) AND subscribers.subscriber_code <= ?', uses, reading_routes, offices, centers, @@period, ReadingType.billable,to_subscriber) \
                                .group('subscribers.id') \
                                .includes(:meter, street_directory: :street_type)
      else
        @@subscribers = Subscriber.select('subscribers.id, subscriber_code, last_name, first_name, company, street_directory_id, street_number, building, floor, floor_office, subscribers.meter_id') \
                                .joins(:readings) \
                                .where('subscribers.active=TRUE AND (subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?)', uses, reading_routes, offices, centers, @@period, ReadingType.billable) \
                                .group('subscribers.id') \
                                .includes(:meter, street_directory: :street_type)
      end
    end

    def subscribers_only(uses, reading_routes, offices, centers)
      @@subscribers = Subscriber.select('subscribers.id, subscriber_code, last_name, first_name, company, street_directory_id, street_number, building, floor, floor_office, subscribers.meter_id') \
                                .where('subscribers.active=TRUE AND (subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?)', uses, reading_routes, offices, centers) \
                                .group('subscribers.id') \
                                .includes(:meter, street_directory: :street_type)
    end

    def show_consumptions
      # billing_period_id = params[:subscribers][:period]
      # subscriber_ids = params[:subscribers][:ids].reject(&:empty?)
      readings = [] #Reading.where(billing_period_id: billing_period_id, subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',[1,2,5,6]).order(:reading_date)
      # subscribers = Subscriber.where(id: subscriber_ids)
      # subscribers = Subscriber.where(id: @@subscribers.pluck('subscribers.id'))

      ### SubscriberFiliation is too slow ###
      # subscribers = Subscriber.where(id: @@subscribers.map{ |s| s.subscriber_id })
      # subscribers.each do |subscriber|
      #   @readings << subscriber.readings.where(billing_period_id: @@period).where('reading_type_id IN (?)', ReadingType.billable).order(:reading_date).last
      # end

      @@subscribers.each do |subscriber|
        readings << subscriber.readings.select('readings.id') \
                              .where(billing_period_id: @@period).where('reading_type_id IN (?)', ReadingType.billable) \
                              .order(:reading_date).last
      end
      @@readings = Reading.where(id: readings)
      @readings = @@readings.paginate(:page => params[:page] || 1, :per_page => per_page || 10)

      respond_to do |format|
        format.html
        format.csv { render text: Reading.to_csv(@readings) }
      end
    end

    # This method executes on Apply Tariffs
    def index
      if params[:bills]
        @bills = PreBill.where(pre_group_no: params[:bills]).paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      else
        if session[:office] != '0'
          @bills = PreBill.joins(:project).where(projects: {office_id: session[:office].to_i}).paginate(:page => params[:page] || 1, :per_page => per_page || 10)
          # @bills = Office.find(session[:office]).subscribers.map(&:pre_bills).flatten.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        else
          @bills = PreBill.all.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        end
      end
      if @bills.empty?
        redirect_to pre_index_bills_path, notice: I18n.t("ag2_gest.bills.index.no_pre_group")
      else
        @bills2 = PreBill.where(pre_group_no: params[:bills])
        @totals = @bills2.select('count(pre_bills.id) as bills, sum(r2.reading_index-r1.reading_index) as consumptions, sum(pre_invoices.totals) as totals') \
                        .joins('INNER JOIN readings r2 ON pre_bills.reading_2_id=r2.id INNER JOIN readings r1 on pre_bills.reading_1_id=r1.id INNER JOIN pre_invoices ON pre_bills.id=pre_invoices.pre_bill_id') \
                        .first
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @bills }
          format.js
        end
      end
    end

    ### The commented lines of code, are a piece of shit. Do not use them!
    def pre_index
      from  = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      if !to.blank? and !from.blank?
        # @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date >= ? AND bill_date <= ?",from.to_date, to.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        @pre_bills = PreBill.select('pre_group_no, min(bill_date) as billing_date, count(*) as billing_count, min(billing_periods.period) as billing_period, max(bill_id) billed_id, sum(pre_invoices.totals) as billing_total') \
                            .joins('LEFT JOIN (pre_invoices LEFT JOIN billing_periods ON pre_invoices.billing_period_id=billing_periods.id) ON pre_bills.id=pre_invoices.pre_bill_id') \
                            .where(project_id: current_projects_ids) \
                            .where("bill_date BETWEEN ? AND ?", from.to_date, to.to_date) \
                            .group(:pre_group_no) \
                            .paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      elsif !to.blank?
        # @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date <= ?", to.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        @pre_bills = PreBill.select('pre_group_no, min(bill_date) as billing_date, count(*) as billing_count, min(billing_periods.period) as billing_period, max(bill_id) billed_id, sum(pre_invoices.totals) as billing_total') \
                            .joins('LEFT JOIN (pre_invoices LEFT JOIN billing_periods ON pre_invoices.billing_period_id=billing_periods.id) ON pre_bills.id=pre_invoices.pre_bill_id') \
                            .where(project_id: current_projects_ids) \
                            .where("bill_date <= ?", to.to_date) \
                            .group(:pre_group_no) \
                            .paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      elsif !from.blank?
        # @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date >= ?", from.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        @pre_bills = PreBill.select('pre_group_no, min(bill_date) as billing_date, count(*) as billing_count, min(billing_periods.period) as billing_period, max(bill_id) billed_id, sum(pre_invoices.totals) as billing_total') \
                            .joins('LEFT JOIN (pre_invoices LEFT JOIN billing_periods ON pre_invoices.billing_period_id=billing_periods.id) ON pre_bills.id=pre_invoices.pre_bill_id') \
                            .where(project_id: current_projects_ids) \
                            .where("bill_date >= ?", from.to_date) \
                            .group(:pre_group_no) \
                            .paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      else
        # @pre_bills = PreBill.where(project_id: current_projects_ids).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        @pre_bills = PreBill.select('pre_group_no, min(bill_date) as billing_date, count(*) as billing_count, min(billing_periods.period) as billing_period, max(bill_id) billed_id, sum(pre_invoices.totals) as billing_total') \
                            .joins('LEFT JOIN (pre_invoices LEFT JOIN billing_periods ON pre_invoices.billing_period_id=billing_periods.id) ON pre_bills.id=pre_invoices.pre_bill_id') \
                            .where(project_id: current_projects_ids) \
                            .group(:pre_group_no) \
                            .paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      end
      # Resume info
      if !params[:pre_bill_no].blank?
        @invoices_by_biller = PreBill.select('companies.name as company,min(invoices.invoice_no) as from_no,max(invoices.invoice_no) as to_no,sum(invoices.totals) as invoiced_total') \
                                     .joins('INNER JOIN (bills INNER JOIN (invoices LEFT JOIN companies ON invoices.biller_id=companies.id) ON bills.id=invoices.bill_id) ON pre_bills.bill_id=bills.id') \
                                     .where('pre_bills.pre_group_no = ? AND pre_bills.bill_id IS NOT NULL', params[:pre_bill_no]) \
                                     .group('invoices.biller_id')
        # @invoices_by_biller = PreBill.where("pre_group_no = ? AND bill_id IS NOT NULL", params[:pre_bill_no]).map(&:bill).map(&:invoices).flatten.group_by(&:biller_id)
      end

      respond_to do |format|
        format.html # pre_index.html.erb
        format.json { render json: @pre_bills }
        format.js
      end
    end

    # GET /bills/1
    # GET /bills/1.json
    def show
      @breadcrumb = 'read'
      @bill = Bill.find(params[:id])
      @invoice = @bill.invoices.paginate(:page => params[:page], :per_page => per_page).order('id')
      # @items = @invoice.invoice_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @billing_periods = billing_periods_dropdown
      if !@bill.water_supply_contract.nil?
        @water_supply_contract = @bill.water_supply_contract
        @contracting_request = @water_supply_contract.contracting_request
        respond_to do |format|
          format.html { render "ag2_gest/contracting_requests/bill" }
          format.json { render json: @bill }
        end
      else
        @reading = @bill.reading
        @subscriber = @bill.subscriber
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @bill }
        end
      end
    end

    def show_test
      @breadcrumb = 'read'
    end

    # GET /bills/new
    # GET /bills/new.json
    def new
      @breadcrumb = 'create'
      @billing_periods = billing_periods_dropdown #.select{|b| b.pre_readings.empty?}
      @uses = uses_dropdown
      @reading_routes = reading_routes_dropdown #.select{|r| r.pre_readings.empty?}
      @centers = Center.all
      # @bill = Bill.new

      # respond_to do |format|
      #   format.html # new.html.erb
      #   format.json { render json: @bill }
      # end

    end

    # GET /bills/1/edit
    def edit
      @bill = Bill.find(params[:id])
    end

    # <<<<<<< AG2GEST
        # # POST /bills
        # # POST /bills.json
        # def create
        #   # readings_ids = params[:bill][:readings][0...-1][1..-1].split(", ")
        #   # readings = Reading.where(id: readings_ids)
        #   @bills = []
        #   group_no = PreBill.next_no
        #   # must be thread
        #   @@readings.each do |r|
        #     @bills << r.generate_pre_bill(group_no)
    # =======
        def status_prebills
          works = current_user.wcreating_pending
          works_complete = works.select{|w| Sidekiq::Status::complete? w.work_no}
          unless works_complete.blank? #Sidekiq::Status::complete? session[:prebills_job_no]
            work = works_complete.first
            group_no = work.group_no #session[:prebills_group_no]
            head 404 and return if group_no.blank?
            # session[:prebills_job_no] = nil
            # session[:prebills_group_no] = nil
            works_complete.first.update_attributes(complete: true, status: Sidekiq::Status::status(works_complete.first.work_no))
            response_hash = { message: "El grupo de prefacturas num. #{group_no} ha finalizado de procesarse. ", link_resume: bills_path(bills: group_no), text_resume: 'Click aqui para verlas'}
            # ActiveRecord::Base.connection.close
            respond_to do |format|
              format.json { render json: response_hash }
            end
          else #if Sidekiq::Status::queued? session[:prebills_job_no] or Sidekiq::Status::working? session[:prebills_job_no]
            respond_to do |format|
              format.json { render json: {}, :status => 202 }
            end
          # else
          #   session[:prebills_job_no] = nil
          #   session[:prebills_group_no] = nil
          #   # ActiveRecord::Base.connection.close
          #   respond_to do |format|
          #     format.json { render json: {}, :status => 500 }
          #   end
          end
        end

        def status_confirm
          works = current_user.wconfirm_pending
          works_complete = works.select{|w| Sidekiq::Status::complete? w.work_no}
          unless works_complete.blank?
            work = works_complete.first
            group_no = work.group_no
            head 404 and return if group_no.blank?
            works_complete.first.update_attributes(complete: true, status: Sidekiq::Status::status(works_complete.first.work_no))
            response_hash = { message: "El grupo de facturas num. #{group_no} ha finalizado de confirmarse. ", link_resume: pre_index_bills_path( modal: "true",
                                    pre_bill_no: group_no,# params[:pre_bill][:ids],
                                    total: work.price_total,# final_bills.sum(&:total),
                                    pre_bills: work.total,# pre_bills_count,
                                    count: work.total_confirmed,# final_bills.count,
                                    consumptions: work.consumption,# final_bills.map{|b| b.reading_2}.sum(&:consumption),
                                    invoice_date: work.invoice_date,# invoice_date,
                                    payday_limit: work.payday_limit,# payday_limit,
                                    first_bill: work.first_bill,# (final_bills.first.full_no unless final_bills.blank?),
                                    last_bill: work.last_bill,# (final_bills.last.full_no unless final_bills.blank?)
                                  ), text_resume: 'Click aqui para verlas'}
            respond_to do |format|
              format.json { render json: response_hash }
              # redirect_to pre_index_bills_path( modal: "true",
              #                         pre_bill_no: params[:pre_bill][:ids],
              #                         total: final_bills.sum(&:total),
              #                         pre_bills: pre_bills_count,
              #                         count: final_bills.count,
              #                         consumptions: final_bills.map{|b| b.reading_2}.sum(&:consumption),
              #                         invoice_date: invoice_date,
              #                         payday_limit: payday_limit,
              #                         first_bill: (final_bills.first.full_no unless final_bills.blank?),
              #                         last_bill: (final_bills.last.full_no unless final_bills.blank?)
              #                       )

            end
          else
            respond_to do |format|
              format.json { render json: {}, :status => 202 }
            end
          end
        end

        def confirm
          pre_bills_ids = params[:pre_bill][:ids]
          payday_limit = params[:pre_bill][:payday_limit]
          invoice_date = params[:pre_bill][:invoice_date]
          confirmation_date = params[:pre_bill][:confirmation_date]
          user_id = current_user.nil? ? nil : current_user.id
          job_id = BillsWorker.perform_async(pre_bills_ids, payday_limit, invoice_date, confirmation_date, user_id)
          BackgroundWork.create(user_id: user_id,
                                work_no: job_id,
                                group_no: pre_bills_ids.to_i,
                                total: 0,
                                failure: "",
                                status: Sidekiq::Status::status(job_id),
                                type_work: "confirm_prebills",
                                invoice_date: invoice_date,
                                payday_limit: payday_limit.blank? ? invoice_date : payday_limit)

          redirect_to pre_index_bills_path, notice: t('activerecord.attributes.bill.confirm_query')

          # @pre_bills = PreBill.where(pre_group_no: params[:pre_bill][:ids], bill_id: nil)
          # pre_bills_count = @pre_bills.count
          # by_user = current_user.nil? ? nil : current_user.id
          # payday_limit = params[:pre_bill][:payday_limit]
          # invoice_date = params[:pre_bill][:invoice_date]
          # final_bills = []
          # @pre_bills.each do |pre_bill|
          #   reading_ids_subscriber_period = pre_bill.subscriber.readings.where(billing_period_id: pre_bill.reading_2.billing_period_id).map(&:id)
          #   if Bill.where(reading_2_id: reading_ids_subscriber_period).blank? and Bill.select{|b| b.bill_operation == InvoiceOperation::INVOICE and b.bill_period == pre_bill.reading_2.billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == pre_bill.subscriber_id}.blank?
          #     @bill = Bill.create!( bill_no: bill_next_no(pre_bill.project),
          #       project_id: pre_bill.project_id,
          #       # project_id: pre_bill.reading.project_id,
          #       invoice_status_id: InvoiceStatus::PENDING,
          #       bill_date: invoice_date,
          #       subscriber_id: pre_bill.subscriber_id,
          #       client_id: pre_bill.client_id,
          #       last_name: pre_bill.last_name,
          #       first_name: pre_bill.first_name,
          #       company: pre_bill.company,
          #       fiscal_id: pre_bill.fiscal_id,
          #       street_type_id: pre_bill.street_type_id,
          #       street_name: pre_bill.street_name,
          #       street_number: pre_bill.street_number,
          #       building: pre_bill.building,
          #       floor: pre_bill.floor,
          #       floor_office: pre_bill.floor_office,
          #       zipcode_id: pre_bill.zipcode_id,
          #       town_id: pre_bill.town_id,
          #       province_id: pre_bill.province_id,
          #       region_id: pre_bill.region_id,
          #       country_id: pre_bill.country_id,
          #       created_by: by_user,
          #       reading_1_id: pre_bill.reading_1_id,
          #       reading_2_id: pre_bill.reading_2_id,
          #       organization_id: pre_bill.project.organization_id )
          #     pre_bill.pre_invoices.map do |pre_invoice|
          #       @invoice = Invoice.create!( invoice_no: invoice_next_no(pre_bill.project.company_id, pre_bill.project.office_id),
          #         bill_id: @bill.id,
          #         invoice_status_id: InvoiceStatus::PENDING,
          #         invoice_type_id: InvoiceType::WATER,
          #         invoice_date: invoice_date,
          #         tariff_scheme_id: pre_invoice.tariff_scheme_id,
          #         payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
          #         invoice_operation_id: InvoiceOperation::INVOICE,
          #         billing_period_id: pre_invoice.billing_period_id,
          #         consumption: pre_invoice.consumption,
          #         consumption_real: pre_invoice.consumption_real,
          #         consumption_estimated: pre_invoice.consumption_estimated,
          #         consumption_other: pre_invoice.consumption_other,
          #         biller_id: pre_invoice.biller_id,
          #         discount_pct: pre_invoice.discount_pct,
          #         exemption: pre_invoice.exemption,
          #         charge_account_id: pre_invoice.charge_account_id,
          #         created_by: by_user,
          #         reading_1_date: pre_invoice.reading_1_date,
          #         reading_2_date: pre_invoice.reading_2_date,
          #         reading_1_index: pre_invoice.reading_1_index,
          #         reading_2_index: pre_invoice.reading_2_index,
          #         organization_id: pre_bill.project.organization_id )
          #       pre_invoice.pre_invoice_items.map do |pre_invoice_item|
          #         InvoiceItem.create!( invoice_id: @invoice.id,
          #           code: pre_invoice_item.code,
          #           description: pre_invoice_item.description,
          #           tariff_id: pre_invoice_item.tariff_id,
          #           price:  pre_invoice_item.price,
          #           quantity: pre_invoice_item.quantity,
          #           tax_type_id: pre_invoice_item.tax_type_id,
          #           discount_pct: pre_invoice_item.discount_pct,
          #           discount: pre_invoice_item.discount,
          #           product_id: pre_invoice_item.product_id,
          #           subcode: pre_invoice_item.subcode,
          #           measure_id: pre_invoice_item.measure_id,
          #           created_by: by_user
          #         )
          #       end
          #       @bill.reading_2.update_attributes(bill_id: @bill.id)
          #       pre_bill.update_attributes(bill_id: @bill.id,confirmation_date: params[:pre_bill][:confirmation_date])
          #       # add mj
          #       pre_invoice.update_attributes(invoice_id: @invoice.id,confirmation_date: params[:pre_bill][:confirmation_date])
          #     end
          #     # add mj
          #     final_bills << @bill
          #   end
          # end
          # # params for modal
          # redirect_to pre_index_bills_path( modal: "true",
          #                                   pre_bill_no: params[:pre_bill][:ids],
          #                                   total: final_bills.sum(&:total),
          #                                   pre_bills: pre_bills_count,
          #                                   count: final_bills.count,
          #                                   consumptions: final_bills.map{|b| b.reading_2}.sum(&:consumption),
          #                                   invoice_date: invoice_date,
          #                                   payday_limit: payday_limit,
          #                                   first_bill: (final_bills.first.full_no unless final_bills.blank?),
          #                                   last_bill: (final_bills.last.full_no unless final_bills.blank?)
          #                                 )
        end

    # POST /bills
    # POST /bills.json
    # def create --> CHANGES NESTOR
    #   @bills = []
    #   group_no = PreBill.next_no
    #   @@readings.each do |r|
    #     @bills << r.generate_pre_bill(group_no)
    #   end
    #   redirect_to bills_path(bills: group_no), notice: t('activerecord.attributes.bill.invoices_created')
    # end

    # def create --> OLD VERSION
    #   # readings_ids = params[:bill][:readings][0...-1][1..-1].split(", ")
    #   # readings = Reading.where(id: readings_ids)
    #   @bills = []
    #   group_no = PreBill.next_no
    #   # must be thread
    #   @@readings.each do |r|
    #     @bills << r.generate_pre_bill(group_no)
    #   end

    #   redirect_to bills_path(bills: group_no), notice: t('activerecord.attributes.bill.invoices_created')

    #   # Thread.new do
    #   #   sleep(10000)
    #   #
    #   #   ActiveRecord::Base.connection.close
    #   # end

    #   # background do
    #   #   sleep(10000)
    #     # recipients = board.account.users.rejecting(current_user)
    #     # recipients.each do |recipient|
    #     #   AccountMailer.new_board(board, current_user, recipient).deliver
    #     # end
    #   # end

    #   # redirect_to ag2_gest.root_path



    #   # @bill = Bill.new(params[:period])
    #   #
    #   # respond_to do |format|
    #   #   if @bill.save
    #   #     format.html { redirect_to @bill, notice: 'Sale offer was successfully created.' }
    #   #     format.json { render json: @bill, status: :created, location: @bill }
    #   #   else
    #   #     format.html { render action: "new" }
    #   #     format.json { render json: @bill.errors, status: :unprocessable_entity }
    #   #   end
    #   # end
    # end

    def create #NEW CREATE FACT OFFLINE
      readings_ids = @@readings.map(&:id) #params[:bill][:readings][0...-1][1..-1].split(", ")
      group_no = PreBill.next_no
      user_id = current_user.nil? ? nil : current_user.id
      job_id = PreBillsWorker.perform_async(readings_ids, group_no, user_id)
      BackgroundWork.create(user_id: current_user.id,
                            work_no: job_id,
                            group_no: group_no,
                            total: 0,
                            failure: "",
                            status: Sidekiq::Status::status(job_id),
                            type_work: "create_prebills" )

      # session[:prebills_job_no] = job_id
      # session[:prebills_group_no] = group_no
      # session[:prebills_total] = readings_ids.count
      redirect_to pre_index_bills_path, notice: t('activerecord.attributes.bill.invoices_query')
    end

    # PUT /bills/1
    # PUT /bills/1.json
    def update
      @bill = Bill.find(params[:id])

      respond_to do |format|
        if @bill.update_attributes(params[:period])
          format.html { redirect_to @bill, notice: t('activerecord.attributes.bill.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @bill.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /bills/1
    # DELETE /bills/1.json
    def destroy
      @bill = PreBill.find(params[:id])
      @bill.destroy

      respond_to do |format|
        format.html { redirect_to bills_path(bills: params[:bills]) }
        format.json { head :no_content }
      end
    end

    private
    # def void_bill(bill)
    #   bill_cancel = bill.dup
    #   if bill_cancel.save
    #     bill.invoices.each do |invoice|
    #       invoice_cancel = Invoice.create(
    #         bill_id: bill_cancel.id,
    #         invoice_no: invoice.invoice_no,
    #         invoice_date: Date.today,
    #         invoice_status_id: invoice.invoice_status_id,
    #         invoice_type_id: 2,
    #         tariff_scheme_id: invoice.tariff_scheme_id,
    #         company_id: invoice.company_id
    #       )
    #       invoice.invoice_items.each do |item|
    #         InvoiceItem.create(
    #           invoice_id: invoice_cancel.id,
    #           code: item.code,
    #           description: item.description,
    #           quantity: item.quantity,
    #           price: item.price * -1,
    #           tax_type_id: item.tax_type_id,
    #           discount_pct: item.discount_pct,
    #           tariff_id: item.tariff_id)
    #       end
    #     end
    #   else
    #     return false
    #   end
    # end

    # def billing_periods_dropdown
    #   _a = Invoice.joins("inner join pre_invoices on invoices.id = pre_invoices.invoice_id")
    #   _b = _a.where(invoice_type_id: 1)
    #   _c = _b.group(:billing_period_id)
    #   _j = []
    #   _c.each do |l|
    #     _j = _j << l.billing_period_id
    #   end
    #   _billing_periods = BillingPeriod.where("NOT id IN (?)",_j).order("period DESC")
    # end

    def billing_periods_dropdown
      BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
    end

    def uses_dropdown
      Use.order("code DESC")
    end

    def reading_routes_dropdown
      ReadingRoute.where(project_id: current_projects_ids).order("name")
    end

    def background(&block)
      Thread.new do
        yield
        # ActiveRecord::Base.connection.close
      end
    end

  end
end
