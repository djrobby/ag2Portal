require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ClientPaymentsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Must authorize manually for every action in this controller
    skip_load_and_authorize_resource :only => [:cp_remove_filters,
                                               :cp_restore_filters,
                                               :cp_format_number,
                                               :cp_format_number_4]
    # Helper methods for
    # => index filters
    helper_method :cp_remove_filters, :cp_restore_filters

    # Format numbers properly
    def cp_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end
    def cp_format_number_4
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    def cash
      invoices = Invoice.find_all_by_id(params[:client_payment][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      amount = BigDecimal.new(params[:client_payment][:amount])
      payment_method = params[:client_payment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      acu = amount
      # Receipt No.
      receipt_no = receipt_next_no(invoices.first.invoice_no[3..4]) || '0000000000'
      invoices.each do |i|
        if acu > 0
          if acu >= i.debt
            amount_paid = i.debt
            acu -= i.debt
            confirmation_date = nil
            invoice_status = InvoiceStatus::CASH
          else
            amount_paid = acu
            acu = 0
            confirmation_date = nil
            invoice_status = InvoiceStatus::PENDING
          end
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::CASH, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method, client_id: i.bill.subscriber.client_id, subscriber_id: i.bill.subscriber_id,
                               payment_date: Time.now, confirmation_date: confirmation_date, amount: amount_paid, instalment_id: nil,
                               client_bank_account_id: nil, charge_account_id: i.charge_account_id)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        else
          break
        end
      end
      redirect_to client_payments_path
    end

    def others
      invoices = Invoice.find_all_by_id(params[:client_payment][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      amount = BigDecimal.new(params[:client_payment][:amount])
      payment_method = params[:client_payment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      acu = amount
      invoices.each do |i|
        if acu > 0
          if acu >= i.debt
            amount_paid = i.debt
            acu -= i.debt
            confirmation_date = Time.now
            invoice_status = InvoiceStatus::CHARGED
          else
            amount_paid = acu
            acu = 0
            confirmation_date = nil
            invoice_status = InvoiceStatus::PENDING
          end
          client_payment = ClientPayment.new(receipt_no: nil, payment_type: ClientPayment::OTHERS, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method, client_id: i.bill.subscriber.client_id, subscriber_id: i.bill.subscriber_id,
                               payment_date: Time.now, confirmation_date: confirmation_date, amount: amount_paid, instalment_id: nil,
                               client_bank_account_id: nil, charge_account_id: i.charge_account_id)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        else
          break
        end
      end
      redirect_to client_payments_path
    end

    def collection_payment_methods(_organization)
      _organization != 0 ? PaymentMethod.collections_belong_to_organization(_organization) : PaymentMethod.collections
    end

    def banks
      invoices = Invoice.find_all_by_id(params[:client_payment_bank][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      # Bank order No.
      receipt_no = params[:client_payment_bank][:receipt_no]
      # Payment type & status
      invoice_status = InvoiceStatus::BANK
      payment_method_id = PaymentType.find(ClientPayment::BANK).payment_method_id rescue collection_payment_methods(invoices.first.organization_id)
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(invoices.first.organization_id)
      end
      invoices.each do |i|
        client_bank_account = i.client.active_bank_account
        if !client_bank_account.blank?
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::BANK, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method_id, client_id: i.client.id, subscriber_id: i.subscriber.id,
                               payment_date: Time.now, confirmation_date: nil, amount: i.debt, instalment_id: nil,
                               client_bank_account_id: nil, charge_account_id: i.charge_account_id)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        end
      end # invoices.each
      redirect_to client_payments_path
    end

    def fractionated
      invoices = Invoice.find_all_by_id(params[:instalment][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      bill = invoices.first.bill
      charge = params[:instalment][:charge].to_d
      payment_method_id = params[:instalment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method_id.blank?
      number_quotas = params[:instalment][:number_inst].to_i
      pct_plus = invoices.sum(&:debt) * (charge/100)
      quota_total = invoices.sum(&:debt) + pct_plus
      single_quota = (quota_total / number_quotas).round(4)
      plan = InstalmentPlan.create( instalment_no: "000000000000-000",
                      instalment_date: Date.today,
                      payment_method_id: payment_method_id,
                      client_id: bill.subscriber.client_id,
                      subscriber_id: bill.subscriber_id,
                      surcharge_pct: charge)
      (1..number_quotas).to_a.each do |q|
        Instalment.create( instalment_plan_id: plan.id,
                    bill_id: bill.id,
                    invoice_id: nil,
                    instalment: q,
                    payday_limit: Date.today + q.month,
                    amount: single_quota,
                    surcharge: (charge / number_quotas) )
      end
      invoices.each do |i|
        i.invoice_status_id = 5
        i.save
      end
      redirect_to client_payments_path
    end

    def instalment
      instalment_ids = params[:payment_fractionated][:ids].split(",")
      instalments = Instalment.where(id: instalment_ids)
      instalments.each do |instalment|
        bill = instalment.bill
        instalment_plan = instalment.instalment_plan
        client_payment = ClientPayment.new(receipt_no: "000-0000-0000", payment_type: 3, bill_id: bill.id, invoice_id: nil,
                             payment_method_id: instalment_plan.payment_method_id, client_id: bill.subscriber.client_id, subscriber_id: bill.subscriber_id,
                             payment_date: Time.now, confirmation_date: Time.now, amount: instalment.amount, instalment_id: instalment.id,
                             client_bank_account_id: nil, charge_account_id: nil)
        if client_payment.save
          if  instalment_plan.instalments.count == instalment_plan.instalments.map(&:client_payment).compact.count
            bill.invoices.each do |i|
              i.invoice_status_id = 99
              i.save
            end
          end
        end
      end
      redirect_to client_payments_path, notice: "Cobro realizado con exito"
    end

    def close_cash
      if !current_projects_ids.blank?
        @bills = Bill.where(project_id: current_projects_ids)
        @client_payments_cash = @bills.where("invoice_status_id < 99").
                                      order("created_at DESC").
                                      map(&:invoices).flatten.
                                      map(&:client_payments).flatten.
                                      select{|c| c.payment_type == ClientPayment::CASH and c.confirmation_date.nil?}
        @client_payments_cash.each do |cp|
          cp.update_attributes(confirmation_date: Time.now)
          if cp.invoice.debt == 0
            cp.invoice.update_attributes(invoice_status_id: 99)
          end
        end
        redirect_to client_payments_path, notice: "Caja cerrada con exito"
      else
        redirect_to client_payments_path, alert: "Error al cerrar la caja"
      end
    end

    def confirm_bank
      client_payment_ids = params[:bank_confirm][:ids].split(",")
      client_payments = ClientPayment.where(id: client_payment_ids)
      client_payments.each do |cp|
        cp.update_attributes(confirmation_date: Time.now)
        cp.invoice.update_attributes(invoice_status_id: 99)
      end
      redirect_to client_payments_path, notice: "Pagos confirmados con exito"
    end

    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      client = params[:Client]
      subscriber = params[:Subscriber]
      street_name = params[:StreetName]
      bank_account = params[:BankAccount] == t(:yes_on) ? true : false
      period = params[:Period]

      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @project = !project.blank? ? Project.find(project).full_name : " "
      @period = !period.blank? ? BillingPeriod.find(period).to_label : " "
      @have_bank_account = have_bank_account_array
      @payment_methods = payment_methods_dropdown

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      client = !client.blank? ? inverse_client_search(client) : client
      subscriber = !subscriber.blank? ? inverse_subscriber_search(subscriber) : subscriber
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name
      current_projects = current_projects_ids

      search_pending = Bill.search do
        with(:invoice_status_id, 0..98)
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(Bill).include = [{client: :client_bank_accounts}, :invoice_status, :payment_method, :invoices, {invoice_items: :tax_type}, :instalments]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      search_charged = Bill.search do
        with :invoice_status_id, InvoiceStatus::CHARGED
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(Bill).include = [{client: :client_bank_accounts}, :invoice_status, :payment_method, :invoices, {invoice_items: :tax_type}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      search_cash = ClientPayment.search do
        with :payment_type, ClientPayment::CASH
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      search_bank = ClientPayment.search do
        with :payment_type, ClientPayment::BANK
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      search_others = ClientPayment.search do
        with :payment_type, ClientPayment::OTHERS
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      search_instalment = Instalment.search do
        with :client_payment, nil
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :bill_no, no
          else
            with(:bill_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        data_accessor_for(Instalment).include = [:bill, {instalment_plan: [:client, :subscriber, :payment_method]}, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      # Initialize datasets
      if no.blank? and client.blank? and subscriber.blank? and project.blank? and bank_account.blank? and period.blank?
        # Return no results
        @bills_pending = Bill.search { with :invoice_status_id, -1 }.results
        @bills_charged = Bill.search { with :invoice_status_id, -1 }.results
      else
        @bills_pending = search_pending.results
        @bills_charged = search_charged.results
      end
      @client_payments_cash = search_cash.results
      @client_payments_bank = search_bank.results
      @client_payments_others = search_others.results
      @instalments = search_instalment.results

      # Initialize totals
      bills_select = 'count(bills.id) as bills, coalesce(sum(invoices.totals),0) as totals'
      payments_select = 'count(id) as payments, coalesce(sum(amount),0) as totals'

      pending_ids = @bills_pending.map(&:id)
      charged_ids = @bills_charged.map(&:id)
      cash_ids = @client_payments_cash.map(&:id)
      bank_ids = @client_payments_bank.map(&:id)
      others_ids = @client_payments_others.map(&:id)
      instalments_ids = @instalments.map(&:id)

      @pending_totals = Bill.select(bills_select).joins(:invoices).where(id: pending_ids).first
      @charged_totals = Bill.select(bills_select).joins(:invoices).where(id: charged_ids).first
      @cash_totals = ClientPayment.select(payments_select).where(id: cash_ids).first
      @bank_totals = ClientPayment.select(payments_select).where(id: bank_ids).first
      @others_totals = ClientPayment.select(payments_select).where(id: others_ids).first
      @instalments_totals = Instalment.select(payments_select).where(id: instalments_ids).first

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: {bills_pending: @bills_pending, bills_charged: @bills_charged, client_payments_cash: @client_payments_cash, client_payments_bank: @client_payments_bank, client_payments_others: @client_payments_others, instalments: @instalments } }
        format.js
      end
    end

    # # bill report
    # def bill_report
    #   manage_filter_state
    #   bill_no = params[:bill_no]
    #   client = params[:client]
    #   subscriber = params[:subscriber]
    #   entity = params[:entity]
    #   project = params[:project]
    #   bank_account = params[:bank_account] == "SI" ? true : false
    #   billing_period = params[:billing_period]
    #   reading_routes = params[:reading_routes]

    #   # OCO
    #   init_oco if !session[:organization]

    #   # If inverse no search is required
    #   bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

    #   @search = Bill.search do
    #     if !current_projects_ids.blank?
    #       with :project_id, current_projects_ids
    #     end
    #     if !bill_no.blank?
    #       if bill_no.class == Array
    #         with :bill_no, bill_no
    #       else
    #         with(:bill_no).starting_with(bill_no)
    #       end
    #     end
    #     if !client.blank?
    #       with :client_id, client
    #     end
    #     if !subscriber.blank?
    #       with :subscriber_id, subscriber
    #     end
    #     if !entity.blank?
    #       with :entity_id, entity
    #     end
    #     if !bank_account.blank?
    #       with :bank_account, bank_account
    #     end
    #     if !reading_routes.blank?
    #       with :reading_route_id, reading_routes
    #     end
    #     order_by :sort_no, :asc
    #     paginate :page => params[:page] || 1, :per_page => Bill.count
    #   end

    #   @bill_report = @search.results

    #   if !@bill_report.blank?
    #     title = t("activerecord.models.bill.few")
    #     @to = formatted_date(@bill_report.first.created_at)
    #     @from = formatted_date(@bill_report.last.created_at)
    #     respond_to do |format|
    #       # Render PDF
    #       format.pdf { send_data render_to_string,
    #                    filename: "#{title}_#{@from}-#{@to}.pdf",
    #                    type: 'application/pdf',
    #                    disposition: 'inline' }
    #     end
    #   end
    # end
    # # bill pending report
    # def bill_pending_report
    #   manage_filter_state
    #   bill_no = params[:bill_no]
    #   client = params[:client]
    #   subscriber = params[:subscriber]
    #   entity = params[:entity]
    #   project = params[:project]
    #   bank_account = params[:bank_account] == "SI" ? true : false
    #   billing_period = params[:billing_period]
    #   reading_routes = params[:reading_routes]

    #   # OCO
    #   init_oco if !session[:organization]

    #   # If inverse no search is required
    #   bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

    #   @search = Bill.search do
    #     with(:invoice_status_id, 0..98)
    #     if !current_projects_ids.blank?
    #       with :project_id, current_projects_ids
    #     end
    #     if !bill_no.blank?
    #       if bill_no.class == Array
    #         with :bill_no, bill_no
    #       else
    #         with(:bill_no).starting_with(bill_no)
    #       end
    #     end
    #     if !client.blank?
    #       with :client_id, client
    #     end
    #     if !subscriber.blank?
    #       with :subscriber_id, subscriber
    #     end
    #     if !entity.blank?
    #       with :entity_id, entity
    #     end
    #     if !bank_account.blank?
    #       with :bank_account, bank_account
    #     end
    #     if !reading_routes.blank?
    #       with :reading_route_id, reading_routes
    #     end
    #     order_by :sort_no, :asc
    #     paginate :page => params[:page] || 1, :per_page => Bill.count
    #   end

    #   @bill_pending_report = @search.results
    #   if !@bill_pending_report.blank?
    #     title = t("activerecord.models.bill.few")
    #     @to = formatted_date(@bill_pending_report.first.created_at)
    #     @from = formatted_date(@bill_pending_report.last.created_at)
    #     respond_to do |format|
    #       # Render PDF
    #       format.pdf { send_data render_to_string,
    #                    filename: "#{title}_#{@from}-#{@to}.pdf",
    #                    type: 'application/pdf',
    #                    disposition: 'inline' }
    #     end
    #   end
    # end
    # # bill unpaid report
    # def bill_unpaid_report
    #   manage_filter_state
    #   bill_no = params[:bill_no]
    #   client = params[:client]
    #   subscriber = params[:subscriber]
    #   entity = params[:entity]
    #   project = params[:project]
    #   bank_account = params[:bank_account] == "SI" ? true : false
    #   billing_period = params[:billing_period]
    #   reading_routes = params[:reading_routes]

    #   # OCO
    #   init_oco if !session[:organization]

    #   # If inverse no search is required
    #   bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

    #   @search = Bill.search do
    #     with(:invoice_status_id, 0..98)
    #     #with :payday_limit, unpaid?
    #     if !current_projects_ids.blank?
    #       with :project_id, current_projects_ids
    #     end
    #     if !bill_no.blank?
    #       if bill_no.class == Array
    #         with :bill_no, bill_no
    #       else
    #         with(:bill_no).starting_with(bill_no)
    #       end
    #     end
    #     if !client.blank?
    #       with :client_id, client
    #     end
    #     if !subscriber.blank?
    #       with :subscriber_id, subscriber
    #     end
    #     if !entity.blank?
    #       with :entity_id, entity
    #     end
    #     if !bank_account.blank?
    #       with :bank_account, bank_account
    #     end
    #     if !reading_routes.blank?
    #       with :reading_route_id, reading_routes
    #     end
    #     order_by :sort_no, :asc
    #     paginate :page => params[:page] || 1, :per_page => Bill.count
    #   end

    #   @bill_unpaid_report = @search.results

    #   if !@bill_unpaid_report.blank?
    #     title = t("activerecord.models.bill.few")
    #     @to = formatted_date(@bill_unpaid_report.first.created_at)
    #     @from = formatted_date(@bill_unpaid_report.last.created_at)
    #     respond_to do |format|
    #       # Render PDF
    #       format.pdf { send_data render_to_string,
    #                    filename: "#{title}_#{@from}-#{@to}.pdf",
    #                    type: 'application/pdf',
    #                    disposition: 'inline' }
    #     end
    #   end
    # end
    # # bill charged report
    # def bill_charged_report
    #   manage_filter_state
    #   bill_no = params[:bill_no]
    #   client = params[:client]
    #   subscriber = params[:subscriber]
    #   entity = params[:entity]
    #   project = params[:project]
    #   bank_account = params[:bank_account] == "SI" ? true : false
    #   billing_period = params[:billing_period]
    #   reading_routes = params[:reading_routes]

    #   # OCO
    #   init_oco if !session[:organization]

    #   # If inverse no search is required
    #   bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

    #   @search = Bill.search do
    #     with :invoice_status_id, 99
    #     if !current_projects_ids.blank?
    #       with :project_id, current_projects_ids
    #     end
    #     if !bill_no.blank?
    #       if bill_no.class == Array
    #         with :bill_no, bill_no
    #       else
    #         with(:bill_no).starting_with(bill_no)
    #       end
    #     end
    #     if !client.blank?
    #       with :client_id, client
    #     end
    #     if !subscriber.blank?
    #       with :subscriber_id, subscriber
    #     end
    #     if !entity.blank?
    #       with :entity_id, entity
    #     end
    #     if !bank_account.blank?
    #       with :bank_account, bank_account
    #     end
    #     if !reading_routes.blank?
    #       with :reading_route_id, reading_routes
    #     end
    #     order_by :sort_no, :asc
    #     paginate :page => params[:page] || 1, :per_page => Bill.count
    #   end

    #   @bill_charged_report = @search.results
    #   if !@bill_charged_report.blank?
    #     title = t("activerecord.models.bill.few")
    #     @to = formatted_date(@bill_charged_report.first.created_at)
    #     @from = formatted_date(@bill_charged_report.last.created_at)
    #     respond_to do |format|
    #       # Render PDF
    #       format.pdf { send_data render_to_string,
    #                    filename: "#{title}_#{@from}-#{@to}.pdf",
    #                    type: 'application/pdf',
    #                    disposition: 'inline' }
    #     end
    #   end
    # end

     # client payment report
    def client_payment_report
      manage_filter_state
      bill_no = params[:bill_no]
      client = params[:client]
      subscriber = params[:subscriber]
      entity = params[:entity]
      project = params[:project]
      bank_account = params[:bank_account] == "SI" ? true : false
      billing_period = params[:billing_period]
      reading_routes = params[:reading_routes]

      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

      @search = ClientPayment.search do
        fulltext params[:search]
        if !current_projects_ids.blank?
          with :project_id, current_projects_ids
        end
        if !bill_no.blank?
          if bill_no.class == Array
            with :bill_no, bill_no
          else
            with(:bill_no).starting_with(bill_no)
          end
        end
        if !client.blank?
          with :client_id, client
        end
        if !subscriber.blank?
          with :subscriber_id, subscriber
        end
        if !entity.blank?
          with :entity_id, entity
        end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => ClientPayment.count
      end

      @client_payment_report = @search.results

      if !@client_payment_report.blank?
        title = t("activerecord.models.client_payment.few")
        @to = formatted_date(@client_payment_report.first.created_at)
        @from = formatted_date(@client_payment_report.last.created_at)
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

    def have_bank_account_array()
      _array = []
      _array = _array << t(:yes_on)
      _array = _array << t(:no_off)
      _array
    end

    def setup_no(no)
      no = no[0] != '%' ? '%' + no : no
      no = no[no.length-1] != '%' ? no + '%' : no
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Bill.where('bill_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.bill_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def inverse_client_search(client)
      _numbers = []
      no = setup_no(client)
      w = "(client_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      Client.where(w).first(1000).each do |i|
        _numbers = _numbers << i.full_name_or_company_code_fiscal
      end
      _numbers = _numbers.blank? ? client : _numbers
    end

    def inverse_subscriber_search(subscriber)
      _numbers = []
      no = setup_no(subscriber)
      w = "(subscriber_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      Subscriber.where(w).first(1000).each do |i|
        _numbers = _numbers << i.code_full_name_or_company_fiscal
      end
      _numbers = _numbers.blank? ? subscriber : _numbers
    end

    def inverse_street_name_search(supply_address)
      _numbers = []
      no = setup_no(supply_address)
      SubscriberSupplyAddress.where('supply_address LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.supply_address
      end
      _numbers = _numbers.blank? ? supply_address : _numbers
    end

    def billing_periods_dropdown
      if !current_projects_ids.blank?
        BillingPeriod.where(project_id: current_projects_ids).order("period")
      else
        BillingPeriod.order("period")
      end
    end

    def reading_routes_dropdown
      if !current_projects_ids.blank?
        ReadingRoute.where(project_id: current_projects_ids).order('name')
      else
        ReadingRoute.order('name')
      end
    end

    def clients_dropdown
      if session[:organization] != '0'
        Client.belongs_to_organization(session[:organization].to_i)
      else
        Client.by_code
      end
    end

    def projects_dropdown
      if !current_projects_ids.blank?
        current_projects
      else
        Project.order("name")
      end
    end

    def subscribers_dropdown
      if session[:office] != '0'
        Subscriber.belongs_to_office(session[:office].to_i)
      else
        Subscriber.by_code
      end
    end

    def entities_dropdown
      Entity.order("created_at DESC")
    end

    def payment_methods_dropdown
      session[:organization] != '0' ? collection_payment_methods(session[:organization].to_i) : collection_payment_methods(0)
    end

    def collection_payment_methods(_organization)
      _organization != 0 ? PaymentMethod.collections_belong_to_organization(_organization) : PaymentMethod.collections
    end

    # Keeps filter state
    def manage_filter_state
      # no
      if params[:No]
        session[:No] = params[:No]
      elsif session[:No]
        params[:No] = session[:No]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # client
      if params[:Client]
        session[:Client] = params[:Client]
      elsif session[:Client]
        params[:Client] = session[:Client]
      end
      # subscriber
      if params[:Subscriber]
        session[:Subscriber] = params[:Subscriber]
      elsif session[:Subscriber]
        params[:Subscriber] = session[:Subscriber]
      end
      # street_name
      if params[:StreetName]
        session[:StreetName] = params[:StreetName]
      elsif session[:StreetName]
        params[:StreetName] = session[:StreetName]
      end
      # bank_account
      if params[:BankAccount]
        session[:BankAccount] = params[:BankAccount]
      elsif session[:BankAccount]
        params[:BankAccount] = session[:BankAccount]
      end
      # period
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
    end

    def cp_remove_filters
      params[:No] = ""
      params[:Project] = ""
      params[:Client] = ""
      params[:Subscriber] = ""
      params[:StreetName] = ""
      params[:BankAccount] = ""
      params[:Period] = ""
      return " "
    end

    def cp_restore_filters
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Client] = session[:Client]
      params[:Subscriber] = session[:Subscriber]
      params[:StreetName] = session[:StreetName]
      params[:BankAccount] = session[:BankAccount]
      params[:Period] = session[:Period]
    end
  end
end
