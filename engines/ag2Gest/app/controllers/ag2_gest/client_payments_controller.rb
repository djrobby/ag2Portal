require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ClientPaymentsController < ApplicationController

    def cash_others
      invoices = Invoice.find_all_by_id(params[:client_payment][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      amount = BigDecimal.new(params[:client_payment][:amount])
      payment_method = params[:client_payment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      payment_type = payment_method.blank? ? 1 : 5
      acu = amount
      invoices.each do |i|
        if acu > 0
          if acu >= i.debt
            amount_paid = i.debt
            acu -= i.debt
            if payment_method.blank?
              confirmation_date = nil
              invoice_status = InvoiceStatus::CASH
            else
              confirmation_date = Time.now
              invoice_status = InvoiceStatus::CHARGED
            end
          else
            amount_paid = acu
            acu = 0
            confirmation_date = nil
            invoice_status = InvoiceStatus::PENDING
          end
          client_payment = ClientPayment.new(receipt_no: "000-0000-0000", payment_type: payment_type, bill_id: i.bill_id, invoice_id: i.id,
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
      redirect_to client_payments_path, notice: "Vuelta de " + acu.to_s
    end

    def banks
      invoices = Invoice.find_all_by_id(params[:client_payment_bank][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      receipt_no = params[:client_payment_bank][:receipt_no]
      payment_method_id = params[:client_payment_bank][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method_id.blank?
      invoice_status = InvoiceStatus::BANK
      invoices.each do |i|
        client_payment = ClientPayment.new(receipt_no: "000-0000-0000", payment_type: 2, bill_id: i.bill_id, invoice_id: i.id,
                             payment_method_id: payment_method_id, client_id: i.bill.subscriber.client_id, subscriber_id: i.bill.subscriber_id,
                             payment_date: Time.now, confirmation_date: nil, amount: i.debt, instalment_id: nil,
                             client_bank_account_id: nil, charge_account_id: i.charge_account_id)
        if client_payment.save
          i.invoice_status_id = invoice_status
          i.save
        end
      end
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
      bill_no = params[:bill_no]
      client = params[:Client]
      subscriber = params[:Subscriber]
      # entity = params[:entity]
      project = params[:Project]
      bank_account = params[:bank_account] == "SI" ? true : false
      billing_period = params[:billing_period]
      reading_routes = params[:reading_routes]

      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @billing_periods = billing_periods_dropdown if @billing_periods.nil?
      @reading_routes = reading_routes_dropdown if @reading_routes.nil?
      @projects  = projects_dropdown if @projects.nil?
      # @clients = clients_dropdown if @clients.nil?
      # @subscribers  = subscribers_dropdown if @subscribers.nil?
      # @entities  = entities_dropdown if @entities.nil?

      # If inverse no search is required
      bill_no = !bill_no.blank? && bill_no[0] == '%' ? inverse_no_search(bill_no) : bill_no

      @search_pending = Bill.search do
        with(:invoice_status_id, 0..98)
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        # if !entity.blank?
        #   with :entity_id, entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @search_charged = Bill.search do
        with :invoice_status_id, 99
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @search_cash = ClientPayment.search do
        with :payment_type, ClientPayment::CASH
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @search_bank = ClientPayment.search do
        with :payment_type, ClientPayment::BANK
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @search_others = ClientPayment.search do
        with :payment_type, ClientPayment::OTHERS
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @search_instalment = Instalment.search do
        with :client_payment, nil
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
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        # if !entity.blank?
        #   fulltext entity
        # end
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !reading_routes.blank?
          with :reading_route_id, reading_routes
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @bills_pending = @search_pending.results
      @bills_charged = @search_charged.results
      @client_payments_cash = @search_cash.results
      @client_payments_bank = @search_bank.results
      @client_payments_others = @search_others.results
      @instalments = @search_instalment.results
      #@reports = reports_array

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

    # def reports_array()
    #   _array = []
    #   _array = _array << t("ag2_gest.client_payments.report.bill_report")
    #   _array = _array << t("ag2_gest.client_payments.report.bill_pending_report")
    #   _array = _array << t("ag2_gest.client_payments.report.bill_unpaid_report")
    #   _array = _array << t("ag2_gest.client_payments.report.bill_charged_report")
    #   _array = _array << t("ag2_gest.client_payments.report.client_payment_report")
    #   _array
    # end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Subscriber.where('subscriber_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.subscriber_code
      end
      _numbers = _numbers.blank? ? no : _numbers
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

    # Keeps filter state
    def manage_filter_state
      # bill_no
      if params[:bill_no]
        session[:bill_no] = params[:bill_no]
      elsif session[:bill_no]
        params[:bill_no] = session[:bill_no]
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
      # entity
      if params[:entity]
        session[:entity] = params[:entity]
      elsif session[:entity]
        params[:entity] = session[:entity]
      end
      # bank_account
      if params[:bank_account]
        session[:bank_account] = params[:bank_account]
      elsif session[:bank_account]
        params[:bank_account] = session[:bank_account]
      end
      # billing_period
      if params[:billing_period]
        session[:billing_period] = params[:billing_period]
      elsif session[:billing_period]
        params[:billing_period] = session[:billing_period]
      end
      # reading_routes
      if params[:reading_routes]
        session[:reading_routes] = params[:reading_routes]
      elsif session[:reading_routes]
        params[:reading_routes] = session[:reading_routes]
      end
    end


  end
end
