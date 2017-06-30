# encoding: utf-8

# Replaceable latin symbols UTF-8 = ASCII-8BIT (ISO-8859-1)
# Á = \xC1  á = \xE1
# É = \xC9  é = \xE9
# Í = \xCD  í = \xED
# Ó = \xD3  ó = \xF3
# Ú = \xDA  ú = \xFA
# Ü = \xDC  ü = \xFC
# Ñ = \xD1  ñ = \xF1
# Ç = \xC7  ç = \xE7
# ¿ = \xBF  ¡ = \xA1
# ª = \xAA  º = \xBA

require_dependency "ag2_gest/application_controller"
require_dependency "ag2_gest/sepa_order"

module Ag2Gest
  class ClientPaymentsController < ApplicationController
    @@last_cash_desk_closing = nil

    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Must authorize manually for every action in this controller
    skip_load_and_authorize_resource :only => [:cp_remove_filters,
                                               :cp_restore_filters,
                                               :cp_format_number,
                                               :cp_format_number_4,
                                               :collection_payment_methods,
                                               :cash,
                                               :cash_instalments,
                                               :open_cash,
                                               :close_cash,
                                               :cash_to_pending,
                                               :others,
                                               :banks,
                                               :bank_instalments,
                                               :confirm_bank,
                                               :bank_to_pending,
                                               :fractionate,
                                               :bank_to_order,
                                               :bank_from_return,
                                               :bank_from_counter]
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

    # Payment method for collection
    def collection_payment_methods(_organization)
      _organization != 0 ? PaymentMethod.collections_belong_to_organization(_organization) : PaymentMethod.collections
    end

    #
    # Cash methods
    #
    def cash
      invoice_ids = params[:client_payment][:invoices_ids].split(",")
      instalment_ids = params[:client_payment][:ids].split(",")
      amount = BigDecimal.new(params[:client_payment][:amount])
      payment_method = params[:client_payment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      # If these are instalments, call cash_instalments & exit
      if !instalment_ids.blank?
        cash_instalments(instalment_ids, amount, payment_method)
        return
      end
      # If these are invoices, go on from here
      invoices = Invoice.find_all_by_id(invoice_ids).sort {|a, b| b[:created_at] <=> a[:created_at]}
      acu = amount
      # Receipt No.
      receipt_no = receipt_next_no(invoices.first.invoice_no[3..4]) || '0000000000'
      invoices.each do |i|
        if acu > 0
          if acu >= i.debt
            amount_paid = i.debt
            acu -= i.debt
            invoice_status = InvoiceStatus::CASH
          else
            amount_paid = acu
            acu = 0
            invoice_status = InvoiceStatus::PENDING
          end
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::CASH, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method, client_id: i.bill.client_id, subscriber_id: i.bill.subscriber_id,
                               payment_date: Time.now, confirmation_date: nil, amount: amount_paid, instalment_id: nil,
                               client_bank_account_id: nil, charge_account_id: i.charge_account_id)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        else
          break
        end
      end
      redirect_to client_payments_path, notice: "Factura/s traspasadas a Caja."
    rescue
      redirect_to client_payments_path, alert: "¡Error!: Imposible traspasar factura/s a Caja."
    end

    def cash_instalments(instalment_ids, amount, payment_method)
      instalments = Instalment.where(id: instalment_ids)
      op = true
      acu = amount
      # Receipt No.
      invoice_no = instalments.first.instalment_invoices.first.invoice.invoice_no
      receipt_no = receipt_next_no(invoice_no[3..4]) || '0000000000'

      # Begin the transaction
      begin
        ActiveRecord::Base.transaction do
          instalments.each do |i|
            if acu > 0
              if acu >= i.debt
                amount_paid = i.debt
                acu -= i.debt
              else
                amount_paid = acu
                acu = 0
              end
              i.instalment_invoices.each do |j|
                client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::CASH, bill_id: j.bill_id, invoice_id: j.invoice_id,
                                     payment_method_id: payment_method, client_id: j.bill.client_id, subscriber_id: j.bill.subscriber_id,
                                     payment_date: Time.now, confirmation_date: nil, amount: amount_paid, instalment_id: i.id,
                                     client_bank_account_id: nil, charge_account_id: j.invoice.charge_account_id)
                if !client_payment.save
                  op = false;
                  break
                else
                  if j.invoice.debt == 0  # No more debt, change invoice status
                    j.invoice.update_attributes(invoice_status_id: InvoiceStatus::CASH)
                  end
                end
              end # i.instalment_invoices.each
              if !op
                redirect_to client_payments_path, alert: "¡Error! Imposible traspasar plazo/s a Caja." and return
                # break
              end
            else
              break
            end
          end   # instalments.each
          redirect_to client_payments_path, notice: "Plazo/s traspasados a Caja."
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path, alert: "¡Error! Imposible traspasar plazo/s a Caja." and return
      end # begin

    # Generic method rescue
    # rescue
    #   redirect_to client_payments_path, alert: "¡Error! Imposible traspasar plazo/s a Caja."
    end

    def open_cash
      current_projects = current_projects_ids
      if !current_projects.blank?
        CashDeskClosing.last_by_project(current_projects)
      elsif session[:office] != '0'
        CashDeskClosing.last_by_office(session[:office].to_i)
      elsif session[:company] != '0'
        CashDeskClosing.last_by_company(session[:company].to_i)
      elsif session[:organization] != '0'
        CashDeskClosing.last_by_organization(session[:organization].to_i)
      else
        CashDeskClosing.last_of_all
      end
    end

    def close_cash
      # Input parameters
      client_payments_ids = params[:close_cash][:client_payments_ids].split(",")
      opening_balance = params[:close_cash][:opening_balance].to_d
      currency_instrument_quantities = params[:currency_instrument][:quantities]
      currency_instrument_ids = params[:currency_instrument][:ids]
      currency_instrument_values = params[:currency_instrument][:values]
      # Last cash desk closing
      last_cash_desk_closing = open_cash
      last_closing = last_cash_desk_closing.id rescue nil
      # Variables
      closing_balance = 0
      amount_collected = 0
      invoices_collected = 0
      created_by = current_user.id if !current_user.nil?
      # Data to process
      client_payments = ClientPayment.where(id: client_payments_ids)
      first_payment = client_payments.first
      organization = first_payment.bill.organization_id rescue nil
      project = first_payment.bill.project_id rescue nil
      company = project.company_id rescue nil
      office = project.office_id rescue nil

      # Begin the transaction
      begin
        ActiveRecord::Base.transaction do
          # Update client payments & invoice statuses
          client_payments.each do |cp|
            amount_collected += cp.amount
            invoices_collected += 1
            cp.update_attributes(confirmation_date: Time.now)
            if cp.invoice.debt == 0
              cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::CHARGED)
            end
          end # client_payments.each
          closing_balance = opening_balance + amount_collected
          # Create cash desk closing
          cash_desk_closing = CashDeskClosing.new(organization_id: organization, company_id: company, office_id: office, project_id: project,
                                                  opening_balance: opening_balance, closing_balance: closing_balance, amount_collected: amount_collected,
                                                  invoices_collected: invoices_collected, last_closing_id: last_closing, created_by: created_by)
          if cash_desk_closing.save
            # Items
            client_payments.each do |cp|
              item = CashDeskClosingItem.new(cash_desk_closing_id: cash_desk_closing.id, client_payment_id: cp.id, amount: cp.amount, type_i: 'C')
              if !item.save
                break
              end
            end # client_payments.each
            # Instruments
            currency_instrument_ids.each_with_index do |id, i|
              quantity = currency_instrument_quantities[i].to_i
              value = currency_instrument_values[i].to_d
              amount = quantity * value
              instrument = CashDeskClosingInstrument.new(cash_desk_closing_id: cash_desk_closing.id, currency_instrument_id: id.to_i, amount: amount, quantity: quantity)
              if !instrument.save
                break
              end
            end # currency_instrument_ids.each_with_index
          end
        end # ActiveRecord::Base.transaction
        redirect_to client_payments_path, notice: "Caja cerrada sin incidencias."
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path, alert: "¡Error! Imposible cerrar Caja." and return
      end # begin
    end

    def cash_to_pending
      client_payments_ids = params[:cash_to_pending][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)
      client_payments.each do |cp|
        cp_instalment = nil
        if cp.instalment_id.blank?
          cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
        else
          cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::FRACTIONATED)
          cp_instalment = cp.instalment
        end
        cp.destroy
        # Sunspot.index! [cp_instalment.instalment_invoices] unless cp_instalment.nil?
      end
      redirect_to client_payments_path, notice: "Factura/s y plazo/s devuelta/o/s a Pendientes sin incidencias."
    rescue
      redirect_to client_payments_path, alert: "¡Error!: Imposible devolver factura/s o plazo/s a Pendientes"
    end

    #
    # Others methods
    #
    def others
      invoices = Invoice.find_all_by_id(params[:client_payment_other][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      amount = BigDecimal.new(params[:client_payment_other][:amount])
      payment_method = params[:client_payment_other][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      acu = amount
      # Receipt No.
      receipt_no = receipt_next_no(invoices.first.invoice_no[3..4]) || '0000000000'
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
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::OTHERS, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method, client_id: i.bill.client_id, subscriber_id: i.bill.subscriber_id,
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

    #
    # Bank methods
    #
    def banks
      invoice_ids = params[:client_payment_bank][:invoices_ids].split(",")
      instalment_ids = params[:client_payment_bank][:ids].split(",")
      # Bank order No.
      receipt_no = params[:client_payment_bank][:receipt_no]
      # If these are instalments, call bank_instalments & exit
      if !instalment_ids.blank?
        bank_instalments(instalment_ids, receipt_no)
        return
      end
      # If these are invoices, go on from here
      invoices = Invoice.find_all_by_id(invoice_ids).sort {|a, b| b[:created_at] <=> a[:created_at]}
      # Payment type & status
      organization_id = invoices.first.organization_id
      invoice_status = InvoiceStatus::BANK
      payment_method_id = PaymentType.find(ClientPayment::BANK).payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end
      # Loop thru invoices and create payments
      invoices.each do |i|
        client_bank_account = i.client.active_bank_account
        if !client_bank_account.blank?
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::BANK, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method_id, client_id: i.client.id, subscriber_id: i.subscriber.id,
                               payment_date: Time.now, confirmation_date: nil, amount: i.debt, instalment_id: nil,
                               client_bank_account_id: client_bank_account.id, charge_account_id: i.charge_account_id)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        end
      end # invoices.each
      redirect_to client_payments_path, notice: "Factura/s domiciliada/s traspasadas a Banco."
    rescue
      redirect_to client_payments_path, alert: "¡Error!: Imposible traspasar factura/s a Banco."
    end

    def bank_instalments(instalment_ids, receipt_no)
      instalments = Instalment.where(id: instalment_ids)
      # Payment type & status
      organization_id = instalments.first.instalment_invoices.first.invoice.organization_id
      payment_method_id = PaymentType.find(ClientPayment::BANK).payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end

      op = true
      # Begin the transaction
      begin
        ActiveRecord::Base.transaction do
          # Loop thru instalments and create payments
          instalments.each do |i|
            client_bank_account = i.instalment_plan.client.active_bank_account
            if !client_bank_account.blank?
              i.instalment_invoices.each do |j|
                client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::BANK, bill_id: j.bill_id, invoice_id: j.invoice_id,
                                     payment_method_id: payment_method_id, client_id: i.instalment_plan.client_id, subscriber_id: i.instalment_plan.subscriber_id,
                                     payment_date: Time.now, confirmation_date: nil, amount: j.debt, instalment_id: i.id,
                                     client_bank_account_id: client_bank_account.id, charge_account_id: j.invoice.charge_account_id)
                if !client_payment.save
                  op = false;
                  break
                else
                  if j.invoice.debt == 0  # No more debt, change invoice status
                    j.invoice.update_attributes(invoice_status_id: InvoiceStatus::BANK)
                  end
                end
              end   # i.instalment_invoices.each
              if !op
                redirect_to client_payments_path, alert: "¡Error! Imposible traspasar plazo/s a Banco." and return
                # break
              end
            end   # !client_bank_account.blank?
          end   # instalments.each
          redirect_to client_payments_path, notice: "Plazo/s domiciliado/s traspasados a Banco."
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path, alert: "¡Error! Imposible traspasar plazo/s a Banco." and return
      end # begin
    end

    def confirm_bank
      client_payment_ids = params[:bank_confirm][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payment_ids)
      client_payments.each do |cp|
        cp.update_attributes(confirmation_date: Time.now)
        cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::CHARGED)
      end
      redirect_to client_payments_path, notice: "Cobros confirmados sin incidencias"
    end

    def bank_to_pending
      client_payments_ids = params[:bank_to_pending][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)
      client_payments.each do |cp|
        cp_instalment = nil
        if cp.instalment_id.blank?
          cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
        else
          cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::FRACTIONATED)
          cp_instalment = cp.instalment
        end
        cp.destroy
        # Sunspot.index! [cp_instalment.instalment_invoices] unless cp_instalment.nil?
      end
      redirect_to client_payments_path, notice: "Factura/s y plazo/s devuelta/o/s a Pendientes sin incidencias."
    rescue
      redirect_to client_payments_path, alert: "¡Error!: Imposible devolver factura/s o plazo/s a Pendientes"
    end

    # Generates & Export SEPA XML file (order, direct debit)
    def bank_to_order
      client_payments_ids = params[:bank_to_order][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)

      # Process only if there is unconfirmed payments
      if client_payments.count > 0
        # Instantiate Class
        sepa = SepaOrder.new(client_payments)

        # Initialize class attributes
        sepa.identificacion_fichero = "PRE"
        sepa.fecha_hora_confeccion = Time.new.strftime("%Y-%m-%d") + "T" + Time.new.strftime("%H:%M:%S")

        # Generate XML object
        xml = sepa.write_xml

        # Write & Upload XML file
        upload_xml_file("bank-to-order.xml", xml)

        # Notify successful ending
        redirect_to client_payments_path, notice: "Factura/s y plazo/s remesados sin incidencias."
      end

    rescue
      redirect_to client_payments_path, alert: "¡Error!: Imposible remesar factura/s o plazo/s."
    end

    # Import SEPA XML file (return, rejections)
    def bank_from_return
    end

    # Import Counter text file (bank counter operations)
    def bank_from_counter
    end

    #
    # Instalments methods
    #
    # Must fractionate invoices from the same client!!
    def fractionate
      # invoices = Invoice.find_all_by_id().sort {|a, b| b[:created_at] <=> a[:created_at]}
      # Params
      invoice_ids = params[:instalment][:invoices_ids].split(",")
      number_quotas = params[:instalment][:number_inst].to_i
      amount_first = params[:instalment][:amount_first].to_d
      charge = params[:instalment][:charge].to_d
      payment_method_id = params[:instalment][:payment_method_id]
      redirect_to client_payments_path, alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method_id.blank?
      created_by = current_user.id if !current_user.nil?

      # Check that all invoices are from the same client
      clients = Client.joins(bills: :invoices).where('invoices.id IN (?)', invoice_ids).select('clients.id').group('clients.id').to_a
      if clients.count > 1
        redirect_to client_payments_path, alert: "Imposible aplazar facturas de varios clientes a la vez."
      end
      client_id = clients.first.id

      # Check that all invoices are from the same subscriber
      subscribers = Subscriber.joins(bills: :invoices).where('invoices.id IN (?)', invoice_ids).select('subscribers.id').group('subscribers.id').to_a
      subscriber_id = nil
      if subscribers.count == 1
        subscriber_id = subscribers.first.id if !subscribers.first.blank?
      end

      # Initialize invoices dataset
      invoices = Invoice.where(id: invoice_ids).joins(:bill, 'LEFT JOIN client_payments ON invoices.id=client_payments.invoice_id') \
                        .select('invoices.*, bills.client_id, bills.subscriber_id, COALESCE(sum(client_payments.amount),0) AS payments, invoices.receivables-COALESCE(sum(client_payments.amount),0) AS debts') \
                        .order('invoices.created_at') \
                        .group('invoices.id')
      organization_id = invoices.first.organization_id

      # Calcs
      invoice_debts = 0
      amount_first_surcharge = 0
      invoices.each { |i| invoice_debts += i.debts }
      invoice_debts_surcharge = invoice_debts * (charge / 100)
      if amount_first > 0
        number_quotas -= 1
        amount_first_surcharge = (amount_first * (charge / 100)).round(4)
        invoice_debts -= amount_first
        invoice_debts_surcharge -= amount_first_surcharge
      end
      each_instalment_amount = (invoice_debts / number_quotas).round(4)
      each_instalment_surcharge = (invoice_debts_surcharge / number_quotas).round(4)

      # Instalment plan No.
      client_id = invoices.first.client.id
      instalment_no = instalment_plan_next_no(client_id) || '0000000000000000000000'

      # Begin the creation transaction
      begin
        ActiveRecord::Base.transaction do
          ### Create plan ###
          plan = InstalmentPlan.create( instalment_no: instalment_no,
                                        instalment_date: Date.today,
                                        payment_method_id: payment_method_id,
                                        client_id: client_id,
                                        subscriber_id: subscriber_id,
                                        surcharge_pct: charge,
                                        created_by: created_by,
                                        organization_id: organization_id )
          ### Create instalments ###
          # Instalment 0
          if amount_first > 0
            Instalment.create( instalment_plan_id: plan.id,
                                instalment: 0,
                                payday_limit: Date.today,
                                amount: amount_first,
                                surcharge: amount_first_surcharge,
                                created_by: created_by )
          end
          # Next instalments
          (1..number_quotas).each do |q|
            Instalment.create( instalment_plan_id: plan.id,
                                instalment: q,
                                payday_limit: Date.today + q.month,
                                amount: each_instalment_amount,
                                surcharge: each_instalment_surcharge,
                                created_by: created_by )
          end
          ### Create deferred invoices ###
          i = 0
          instalment_id = 0
          instalment_balance = 0
          invoice = []
          amount = 0
          debt = 0
          new_debt = 0
          plan.instalments.each do |q|
            instalment_id = q.id
            instalment_balance = q.amount
            # Loop thru invoices
            while instalment_balance > 0.0001
              invoice = invoices[i]
              debt = new_debt > 0 ? new_debt : invoice.debts
              amount = debt > instalment_balance ? instalment_balance : debt
              new_debt = (debt - amount).round(4)
              instalment_balance = (instalment_balance - amount).round(4)
              InstalmentInvoice.create( instalment_id: instalment_id,
                                        bill_id: invoice.bill_id,
                                        invoice_id: invoice.id,
                                        debt: debt,
                                        amount: amount )
              i += 1 if new_debt <= 0.0001
            end
          end

          # Update invoice statuses
          invoices.each do |j|
            j.invoice_status_id = InvoiceStatus::FRACTIONATED
            j.save
          end

          redirect_to client_payments_path, notice: I18n.t('ag2_gest.client_payments.fractionate_ok', var: instalment_no)
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path, alert: I18n.t(:transaction_error, var: "fractionate") and return
      end # begin

    # Generic method rescue
    # rescue
    #   redirect_to client_payments_path, alert: I18n.t('ag2_gest.client_payments.fractionate_error')
    end

    #
    # Default Methods
    #
    # GET /client_payments
    # GET /client_payments.json
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
      @cashier_payment_methods = cashier_payment_methods_dropdown
      @no_cashier_payment_methods = no_cashier_payment_methods_dropdown

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
        with :confirmation_date, nil
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
        with :confirmation_date, nil
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

      search_instalment = InstalmentInvoice.search do
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
        data_accessor_for(InstalmentInvoice).include = [:bill, {instalment: {instalment_plan: [:client, :subscriber, :payment_method]}}, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      # Initialize datasets
      if no.blank? and client.blank? and subscriber.blank? and project.blank? and bank_account.blank? and period.blank?
        # Return no results
        @bills_pending = Bill.search { with :invoice_status_id, -1 }.results
        @bills_charged = Bill.search { with :invoice_status_id, -1 }.results
        @client_payments_others = ClientPayment.search { with :payment_type, -1 }.results
        @instalment_invoices = InstalmentInvoice.search { with :client_id, -1 }.results
      else
        @bills_pending = search_pending.results
        @bills_charged = search_charged.results
        @client_payments_others = search_others.results
        @instalment_invoices = search_instalment.results
      end
      @client_payments_cash = search_cash.results
      @client_payments_bank = search_bank.results

      # Initialize totals
      bills_select = 'count(bills.id) as bills, coalesce(sum(invoices.totals),0) as totals'
      payments_select = 'count(id) as payments, coalesce(sum(amount),0) as totals'
      plans_select = 'count(id) as plans'

      pending_ids = @bills_pending.map(&:id)
      charged_ids = @bills_charged.map(&:id)
      cash_ids = @client_payments_cash.map(&:id)
      bank_ids = @client_payments_bank.map(&:id)
      others_ids = @client_payments_others.map(&:id)
      instalment_invoices_ids = @instalment_invoices.map(&:id)
      instalment_ids = @instalment_invoices.map(&:instalment_id).uniq

      @pending_totals = Bill.select(bills_select).joins(:invoices).where(id: pending_ids).first
      @charged_totals = Bill.select(bills_select).joins(:invoices).where(id: charged_ids).first
      @cash_totals = ClientPayment.select(payments_select).where(id: cash_ids).first
      @bank_totals = ClientPayment.select(payments_select).where(id: bank_ids).first
      @others_totals = ClientPayment.select(payments_select).where(id: others_ids).first
      @instalment_invoices_totals = InstalmentInvoice.select(payments_select).where(id: instalment_invoices_ids).first

      @instalments = Instalment.with_these_ids(instalment_ids).paginate(:page => params[:page], :per_page => per_page || 10)
      @instalments_totals = @instalments.select(payments_select).first
      plan_ids = @instalments.map(&:instalment_plan_id).uniq
      @plans_totals = InstalmentPlan.where(id: plan_ids).select(plans_select).first

      # Open last cash desk closing
      @last_cash_desk_closing = open_cash
      @opening_balance = @last_cash_desk_closing.closing_balance rescue 0
      @closing_balance = @opening_balance + @cash_totals.totals

      # Currencies & instruments
      @currency = Currency.find_by_alphabetic_code('EUR')
      @currency_instruments = CurrencyInstrument.having_currency(@currency.id)

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

    def payment_receipt
      @payment = ClientPayment.find(params[:id])
      @payment_receipt = ClientPayment.where(receipt_no: @payment.receipt_no).group(:bill_id)
      @payment_subscribers = ClientPayment.where(receipt_no: @payment.receipt_no).group(:subscriber_id)
      title = t("activerecord.models.client_payment.few")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@payment.receipt_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

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

    def cashier_payment_methods_dropdown
      session[:organization] != '0' ? collections_used_by_cashier(session[:organization].to_i) : collections_used_by_cashier(0)
    end

    def collections_used_by_cashier(_organization)
      _organization != 0 ? PaymentMethod.collections_by_organization_used_by_cashier(_organization) : PaymentMethod.collections_used_by_cashier
    end

    def no_cashier_payment_methods_dropdown
      session[:organization] != '0' ? collections_not_used_by_cashier(session[:organization].to_i) : collections_not_used_by_cashier(0)
    end

    def collections_not_used_by_cashier(_organization)
      _organization != 0 ? PaymentMethod.collections_by_organization_not_used_by_cashier(_organization) : PaymentMethod.collections_not_used_by_cashier
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
