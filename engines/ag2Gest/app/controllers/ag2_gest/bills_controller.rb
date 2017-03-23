require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'
require_relative 'thinreports-with-text-rotation'

module Ag2Gest
  class BillsController < ApplicationController

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

    #
    # Bulk billing (confirm prebilling)
    #
    def confirm
      @pre_bills = PreBill.where(pre_group_no: params[:pre_bill][:ids], bill_id: nil)
      pre_bills_count = @pre_bills.count
      by_user = current_user.nil? ? nil : current_user.id
      payday_limit = params[:pre_bill][:payday_limit]
      invoice_date = params[:pre_bill][:invoice_date]
      final_bills = []
      @pre_bills.each do |pre_bill|
        reading_ids_subscriber_period = pre_bill.subscriber.readings.where(billing_period_id: pre_bill.reading_2.billing_period_id).map(&:id)
        if Bill.where(reading_2_id: reading_ids_subscriber_period).blank? and Bill.select{|b| b.bill_operation == InvoiceOperation::INVOICE and b.bill_period == pre_bill.reading_2.billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == pre_bill.subscriber_id}.blank?
          @bill = Bill.create!( bill_no: bill_next_no(pre_bill.project),
            project_id: pre_bill.project_id,
            # project_id: pre_bill.reading.project_id,
            invoice_status_id: InvoiceStatus::PENDING,
            bill_date: invoice_date,
            subscriber_id: pre_bill.subscriber_id,
            client_id: pre_bill.client_id,
            last_name: pre_bill.last_name,
            first_name: pre_bill.first_name,
            company: pre_bill.company,
            fiscal_id: pre_bill.fiscal_id,
            street_type_id: pre_bill.street_type_id,
            street_name: pre_bill.street_name,
            street_number: pre_bill.street_number,
            building: pre_bill.building,
            floor: pre_bill.floor,
            floor_office: pre_bill.floor_office,
            zipcode_id: pre_bill.zipcode_id,
            town_id: pre_bill.town_id,
            province_id: pre_bill.province_id,
            region_id: pre_bill.region_id,
            country_id: pre_bill.country_id,
            created_by: by_user,
            reading_1_id: pre_bill.reading_1_id,
            reading_2_id: pre_bill.reading_2_id,
            organization_id: pre_bill.project.organization_id )
          pre_bill.pre_invoices.map do |pre_invoice|
            @invoice = Invoice.create!( invoice_no: invoice_next_no(pre_bill.project.company_id, pre_bill.project.office_id),
              bill_id: @bill.id,
              invoice_status_id: InvoiceStatus::PENDING,
              invoice_type_id: InvoiceType::WATER,
              invoice_date: invoice_date,
              tariff_scheme_id: pre_invoice.tariff_scheme_id,
              payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
              invoice_operation_id: InvoiceOperation::INVOICE,
              billing_period_id: pre_invoice.billing_period_id,
              consumption: pre_invoice.consumption,
              consumption_real: pre_invoice.consumption_real,
              consumption_estimated: pre_invoice.consumption_estimated,
              consumption_other: pre_invoice.consumption_other,
              biller_id: pre_invoice.biller_id,
              discount_pct: pre_invoice.discount_pct,
              exemption: pre_invoice.exemption,
              charge_account_id: pre_invoice.charge_account_id,
              created_by: by_user,
              reading_1_date: pre_invoice.reading_1_date,
              reading_2_date: pre_invoice.reading_2_date,
              reading_1_index: pre_invoice.reading_1_index,
              reading_2_index: pre_invoice.reading_2_index,
              organization_id: pre_bill.project.organization_id )
            pre_invoice.pre_invoice_items.map do |pre_invoice_item|
              InvoiceItem.create!( invoice_id: @invoice.id,
                code: pre_invoice_item.code,
                description: pre_invoice_item.description,
                tariff_id: pre_invoice_item.tariff_id,
                price:  pre_invoice_item.price,
                quantity: pre_invoice_item.quantity,
                tax_type_id: pre_invoice_item.tax_type_id,
                discount_pct: pre_invoice_item.discount_pct,
                discount: pre_invoice_item.discount,
                product_id: pre_invoice_item.product_id,
                subcode: pre_invoice_item.subcode,
                measure_id: pre_invoice_item.measure_id,
                created_by: by_user
              )
            end
            @bill.reading_2.update_attributes(bill_id: @bill.id)
            pre_bill.update_attributes(bill_id: @bill.id,confirmation_date: params[:pre_bill][:confirmation_date])
            # add mj
            pre_invoice.update_attributes(invoice_id: @invoice.id,confirmation_date: params[:pre_bill][:confirmation_date])
          end
          # add mj
          final_bills << @bill
        end
      end
      # params for modal
      redirect_to pre_index_bills_path( modal: "true",
                                        pre_bill_no: params[:pre_bill][:ids],
                                        total: final_bills.sum(&:total),
                                        pre_bills: pre_bills_count,
                                        count: final_bills.count,
                                        consumptions: final_bills.map{|b| b.reading_2}.sum(&:consumption),
                                        invoice_date: invoice_date,
                                        payday_limit: payday_limit,
                                        first_bill: (final_bills.first.full_no unless final_bills.blank?),
                                        last_bill: (final_bills.last.full_no unless final_bills.blank?)
                                      )
    end

    def get_subscribers

      _reading_routes = params[:bill][:reading_routes].reject(&:empty?)
      reading_routes = _reading_routes.blank? ? ReadingRoute.pluck(:id) : _reading_routes
      _offices = current_offices_ids
      offices = _offices.blank? ? Office.pluck(:id) : _offices
      _centers = params[:bill][:centers].reject(&:empty?)
      centers = _centers.blank? ? Center.pluck(:id) : _centers
      period = params[:bill][:period]
      _uses = params[:bill][:use].reject(&:empty?)
      uses = _uses.blank? ? Use.pluck(:id) : _uses

      subscribers = Reading.joins(:subscriber).where("(subscribers.use_id IN (?) OR subscribers.use_id IS NULL) AND subscribers.reading_route_id IN (?) AND subscribers.office_id IN (?) AND subscribers.center_id IN (?) AND readings.billing_period_id = ? AND readings.reading_type_id IN (?)",uses, reading_routes, offices, centers, period, [ReadingType::NORMAL, ReadingType::OCTAVILLA, ReadingType::RETIRADA, ReadingType::AUTO]).select{|r| r.billable?}.map(&:subscriber).uniq

      subscribers_label = subscribers.map{|s| [s.id, "#{s.to_label} #{s.address_1}"]}

      response_hash = { subscribers: subscribers_label}
      respond_to do |format|
        format.json { render json: response_hash }
      end
    end

    def show_consumptions
      # subscribers = Subscriber.where(id: params[:subscribers][:ids].reject(&:empty?))
      # period = Period.find(params[:subscribers][:period])
      billing_period_id = params[:subscribers][:period]
      subscriber_ids = params[:subscribers][:ids].reject(&:empty?)
      @readings = [] #Reading.where(billing_period_id: billing_period_id, subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',[1,2,5,6]).order(:reading_date)
      subscribers  = Subscriber.where(id: subscriber_ids)
      subscribers.each do |subscriber|
        @readings << subscriber.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).last
      end
      respond_to do |format|
        format.html
        format.csv { render text: Reading.to_csv(@readings) }
      end
    end

    def index
      if params[:bills]
        @bills = PreBill.where(pre_group_no: params[:bills]).paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      else
        if session[:office] != '0'
          @bills = Office.find(session[:office]).subscribers.map(&:pre_bills).flatten.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        else
          @bills = PreBill.all.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
        end
      end
      if @bills.empty?
        redirect_to pre_index_bills_path, notice: I18n.t("ag2_gest.bills.index.no_pre_group")
      else
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @bills }
          format.js
        end
      end
    end

    def pre_index
      from  = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      if !to.blank? and !from.blank?
        @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date >= ? AND bill_date <= ?",from.to_date, to.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      elsif !to.blank?
        @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date <= ?", to.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      elsif !from.blank?
        @pre_bills = PreBill.where(project_id: current_projects_ids).where("bill_date >= ?", from.to_date).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      else
        @pre_bills = PreBill.where(project_id: current_projects_ids).group_by{|p| p.pre_group_no }.to_a.paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      end
      # Resume info
      if !params[:pre_bill_no].blank?
        @invoices_by_biller = PreBill.where("pre_group_no = ? AND bill_id IS NOT NULL", params[:pre_bill_no]).map(&:bill).map(&:invoices).flatten.group_by(&:biller_id)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @pre_bills }
        format.js
      end
    end

    # GET /bills/1
    # GET /bills/1.json
    def show

      @breadcrumb = 'read'
      @bill = Bill.find(params[:id])
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

    # POST /bills
    # POST /bills.json
    def create
      readings_ids = params[:bill][:readings][0...-1][1..-1].split(", ")
      readings = Reading.where(id: readings_ids)
      @bills = []
      group_no = PreBill.next_no
      # must be thread
      readings.each do |r|
        @bills << r.generate_pre_bill(group_no)
      end

      redirect_to bills_path(bills: group_no), notice: t('activerecord.attributes.bill.invoices_created')

      # Thread.new do
      #   sleep(10000)
      #
      #   ActiveRecord::Base.connection.close
      # end

      # background do
      #   sleep(10000)
        # recipients = board.account.users.rejecting(current_user)
        # recipients.each do |recipient|
        #   AccountMailer.new_board(board, current_user, recipient).deliver
        # end
      # end

      # redirect_to ag2_gest.root_path



      # @bill = Bill.new(params[:period])
      #
      # respond_to do |format|
      #   if @bill.save
      #     format.html { redirect_to @bill, notice: 'Sale offer was successfully created.' }
      #     format.json { render json: @bill, status: :created, location: @bill }
      #   else
      #     format.html { render action: "new" }
      #     format.json { render json: @bill.errors, status: :unprocessable_entity }
      #   end
      # end
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
      _billing_periods = BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
    end

    def uses_dropdown
      _uses = Use.order("code DESC")
    end

    def reading_routes_dropdown
      _reading_routes = ReadingRoute.where(project_id: current_projects_ids).order("name")
    end

    def background(&block)
      Thread.new do
        yield
        ActiveRecord::Base.connection.close
      end
    end

  end
end
