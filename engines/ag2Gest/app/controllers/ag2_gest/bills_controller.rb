require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillsController < ApplicationController

    def void
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      void_bill(bill)
      redirect_to subscriber_path(@subscriber, bill: @bill.id)
    end

    def rebilling
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      void_bill(bill)
      @reading = @subscriber.readings.find_by_billing_period_id(params[:bills][:billing_period_id])
      @bill = @reading.generate_pre_bill
      redirect_to subscriber_path(@subscriber, bill: @bill.id)
    end

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


    def confirm
      # @bills = Bill.where(id: params[:bills][:ids].split("[\"")[1].split("\"]")[0].split("\", \""))
      @pre_bills = PreBill.where(pre_group_no: params[:pre_bill][:ids], bill_id: nil)
      @pre_bills.each do |pre_bill|
        bill = Bill.create(
          bill_no: bill_next_no(pre_bill.reading.project),
          project_id: pre_bill.reading.project_id,
          invoice_status_id: InvoiceStatus::PENDING,
          bill_date: Date.today,#¿¿¿???
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
          created_by: (current_user.id if current_user)
        )
        pre_bill.update_attributes(bill_id: bill.id, confirmation_date: params[:pre_bill][:confirmation_date])
        pre_bill.pre_invoices.each do |pre_invoice|
          invoice = Invoice.create(
            invoice_no: invoice_next_no(pre_bill.reading.project.company_id),
            bill_id: bill.id,
            invoice_status_id: InvoiceStatus::PENDING,
            invoice_type_id: InvoiceType::WATER,
            invoice_date: Date.today,#¿¿¿???
            tariff_scheme_id: pre_invoice.tariff_scheme_id,
            payday_limit: nil,
            invoice_operation_id: InvoiceOperation::INVOICE,
            billing_period_id: pre_invoice.billing_period_id,
            reading_1_id: nil, #¿¿¿???
            reading_2_id: pre_invoice.reading_2_id,
            consumption: pre_invoice.consumption,
            consumption_real: pre_invoice.consumption_real,
            consumption_estimated: pre_invoice.consumption_estimated,
            consumption_other: pre_invoice.consumption_other,
            biller_id: pre_invoice.biller_id,
            discount_pct: pre_invoice.discount_pct,
            exemption: pre_invoice.exemption,
            charge_account_id: pre_invoice.charge_account_id,
            created_by: (current_user.id if current_user)
          )
          pre_invoice.update_attributes(invoice_id: invoice.id, confirmation_date: params[:pre_bill][:confirmation_date])
          pre_invoice.pre_invoice_items.each do |pre_invoice_item|
            InvoiceItem.create(
              invoice_id: invoice.id,
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
              created_by: (current_user.id if current_user)
            )
          end
        end
      end
      redirect_to pre_index_bills_path
    end

    def get_subscribers
      # if params[:bill][:subscribers].reject(&:empty?).empty?
        subscribers_filter = Subscriber.where(office_id: session[:office].to_i).order(:id)
        subscribers_filter = subscribers_filter.where(reading_route_id: params[:bill][:reading_routes]) unless params[:bill][:reading_routes].reject(&:empty?).empty?
        subscribers_filter = subscribers_filter.where(center_id: params[:bill][:centers]) unless params[:bill][:centers].reject(&:empty?).empty?
        subscribers_ids = subscribers_filter.map(&:id)
        readings = Reading.where(subscriber_id: subscribers_ids).where(billing_period_id: params[:bill][:period])
        subscribers = readings.map(&:subscriber).uniq
      # else
      #   subscribers = Subscriber.where(id: params[:bill][:subscribers].reject(&:empty?))
      #   readings = Reading.where(subscriber_id: params[:bill][:subscribers].reject(&:empty?)).where(billing_period_id: params[:bill][:period])
      # end

      subscribers_label = subscribers.map{|s| [s.id, "#{s.full_name_and_code} #{s.address_1}"]}

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
      @readings = Reading.where(billing_period_id: billing_period_id).where(subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',ReadingType::INSTALACION)

    end

    def index
      if params[:bills]
        @bills = PreBill.where(pre_group_no: params[:bills])
      else
        @bills = Office.find(session[:office]).subscribers.map(&:pre_bills).flatten
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bills }
      end
    end

    def pre_index
      @pre_bills = PreBill.where(project_id: current_projects_ids).group_by{|p| p.pre_group_no }
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
    def void_bill(bill)
      bill_cancel = bill.dup
      if bill_cancel.save
        bill.invoices.each do |invoice|
          invoice_cancel = Invoice.create(
            bill_id: bill_cancel.id,
            invoice_no: invoice.invoice_no,
            invoice_date: Date.today,
            invoice_status_id: invoice.invoice_status_id,
            invoice_type_id: 2,
            tariff_scheme_id: invoice.tariff_scheme_id,
            company_id: invoice.company_id
          )
          invoice.invoice_items.each do |item|
            InvoiceItem.create(
              invoice_id: invoice_cancel.id,
              code: item.code,
              description: item.description,
              quantity: item.quantity,
              price: item.price * -1,
              tax_type_id: item.tax_type_id,
              discount_pct: item.discount_pct,
              tariff_id: item.tariff_id)
          end
        end
      else
        return false
      end
    end

    def billing_periods_dropdown
      _billing_periods = BillingPeriod.where(project_id: current_projects_ids).order("period DESC")
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
