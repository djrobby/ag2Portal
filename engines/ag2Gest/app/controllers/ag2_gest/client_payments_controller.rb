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
require_dependency "ag2_gest/sepa_return"
require_dependency "ag2_gest/sepa_counter"

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
                                               :reload_current_search,
                                               :collection_payment_methods,
                                               :cash,
                                               :cash_instalments,
                                               :open_cash,
                                               :close_cash,
                                               :cash_to_pending,
                                               :others,
                                               :confirm_others,
                                               :others_to_pending,
                                               :banks,
                                               :bank_instalments,
                                               :confirm_bank,
                                               :bank_to_pending,
                                               :fractionate,
                                               :bank_to_order,
                                               :bank_from_return,
                                               :bank_from_counter,
                                               :payment_receipt,
                                               :client_payment_view_report]
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

    # Change contents of current tab (cash, bank, instalment & other)
    def reload_current_search
      tab = params[:tab]
      all = params[:all]
      notice = I18n.t('ag2_gest.client_payments.index.reload')
      per_page = ''

      case tab
      when 'cash'
        if all == 'true'
          per_page = ClientPayment.in_cash.size
        end
        params[:per_page_cash] = per_page
        notice = I18n.t('ag2_gest.client_payments.index.reload_cash')
      when 'bank'
        if all == 'true'
          per_page = ClientPayment.in_bank.size
        end
        params[:per_page_bank] = per_page
        notice = I18n.t('ag2_gest.client_payments.index.reload_bank')
      when 'instalment'
        if all == 'true'
          per_page = ClientPayment.in_deferrals.size
        end
        params[:per_page_deferrals] = per_page
        notice = I18n.t('ag2_gest.client_payments.index.reload_deferrals')
      when 'other'
        if all == 'true'
          per_page = ClientPayment.in_others.size
        end
        params[:per_page_others] = per_page
        notice = I18n.t('ag2_gest.client_payments.index.reload_other')
      end

      json_data = { "notice" => notice, "per_page" => per_page, "all" => all }
      render json: json_data
      # redirect_to client_payments_path, notice: notice
    end

    # Payment method for collection
    def collection_payment_methods(_organization)
      _organization != 0 ? PaymentMethod.collections_belong_to_organization(_organization) : PaymentMethod.collections
    end

    #
    # Cash methods
    #
    # If amount <= 0, must charge every invoice debts!
    def cash
      # Set active_tab to use in view filters
      session[:active_tab] = "pendings-tab"

      invoice_ids = params[:client_payment][:invoices_ids].split(",")
      instalment_ids = params[:client_payment][:ids].split(",")
      amount = BigDecimal.new(params[:client_payment][:amount]) rescue 0  # 0 if error beause :amount is null and debt negative
      payment_method = params[:client_payment][:payment_method_id]
      redirect_to client_payments_path + "#tab_pendings", alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      # If these are instalments, call cash_instalments & exit
      if !instalment_ids.blank?
        cash_instalments(instalment_ids, amount, payment_method)
        return
      end
      # If these are invoices, go on from here
      client_payment = nil
      invoices = Invoice.find_all_by_id(invoice_ids).sort_by {|a| a[:created_at]}
      created_by = current_user.id if !current_user.nil?
      acu = amount
      # Receipt No.
      receipt_no = receipt_next_no(invoices.first.invoice_no[3..4]) || '0000000000'
      invoices.each do |i|
        if amount > 0
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
          else
            break
          end # acu > 0
        else
          amount_paid = i.debt
          invoice_status = InvoiceStatus::CASH
        end # amount > 0
        client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::CASH, bill_id: i.bill_id, invoice_id: i.id,
                             payment_method_id: payment_method, client_id: i.bill.client_id, subscriber_id: i.bill.subscriber_id,
                             payment_date: Time.now, confirmation_date: nil, amount: amount_paid, instalment_id: nil,
                             client_bank_account_id: nil, charge_account_id: i.charge_account_id, created_by: created_by)
        if client_payment.save
          i.invoice_status_id = invoice_status
          i.save
        end
      end # invoices.each do
      redirect_to client_payments_path + "#tab_pendings", notice: (I18n.t('ag2_gest.client_payments.index.cash_ok') + " #{view_context.link_to I18n.t('ag2_gest.client_payments.index.click_to_print_receipt'), payment_receipt_client_payment_path(client_payment, :format => :pdf), target: '_blank'}").html_safe
      # redirect_to client_payments_path, notice: "Recibo/Factura/s traspasados/as a Caja."
    rescue
      redirect_to client_payments_path + "#tab_pendings", alert: I18n.t('ag2_gest.client_payments.index.cash_error')
    end

    def cash_instalments(instalment_ids, amount, payment_method)
      # Set active_tab to use in view filters
      session[:active_tab] = "fractionated-tab"

      client_payment = nil
      instalments = Instalment.where(id: instalment_ids)
      op = true
      created_by = current_user.id if !current_user.nil?
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
                                     client_bank_account_id: nil, charge_account_id: j.invoice.charge_account_id, created_by: created_by)
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
                redirect_to client_payments_path + "#tab_fractionated", alert: "¡Error! Imposible traspasar plazo/s a Caja." and return
                # break
              end
            else
              break
            end
          end   # instalments.each
          redirect_to client_payments_path + "#tab_fractionated", notice: (I18n.t('ag2_gest.client_payments.index.cash_instalments_ok') + " #{view_context.link_to I18n.t('ag2_gest.client_payments.index.click_to_print_receipt'), payment_receipt_client_payment_path(client_payment, :format => :pdf), target: '_blank'}").html_safe
          # redirect_to client_payments_path, notice: "Plazo/s traspasados a Caja."
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path + "#tab_fractionated", alert: "¡Error! Imposible traspasar plazo/s a Caja." and return
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
      # Set active_tab to use in view filters
      session[:active_tab] = "cash-tab"

      # Input parameters
      client_payments_ids = params[:close_cash][:client_payments_ids].split(",")
      opening_balance = params[:close_cash][:opening_balance].to_d
      currency_instrument_quantities = params[:currency_instrument][:quantities]
      currency_instrument_ids = params[:currency_instrument][:ids]
      currency_instrument_values = params[:currency_instrument][:values]
      currency_instrument_types = params[:currency_instrument][:types]
      # Last cash desk closing
      last_cash_desk_closing = open_cash
      last_closing = last_cash_desk_closing.id rescue nil
      # Variables
      closing_balance = 0
      amount_collected = 0
      invoices_collected = 0
      amount_paid = 0
      invoices_paid = 0
      amount_others = 0
      quantity_others = 0
      instruments_difference = 0
      created_by = current_user.id if !current_user.nil?
      # SELECT for payment & other totals
      payments_select = 'count(supplier_payments.id) as payments, coalesce(sum(supplier_payments.amount),0)*(-1) as totals'
      others_select = 'count(cash_movements.id) as movements, coalesce(sum(cash_movements.amount),0) as totals'
      # Data to process
      # Client payments
      project = nil
      company = nil
      office = nil
      client_payments = ClientPayment.where(id: client_payments_ids)
      first_payment = client_payments.first
      organization = first_payment.bill.organization_id rescue nil
      prj = first_payment.bill.project rescue nil
      project = prj.id rescue nil
      company = prj.company_id rescue nil
      office = prj.office_id rescue nil
      # Supplier payments
      w = ''
      w = "supplier_payments.organization_id = #{organization} AND " if !organization.nil?
      w = "supplier_invoices.company_id = #{company} AND " if !company.nil?
      w = "projects.office_id = #{office} AND " if !office.nil?
      # w = "supplier_invoices.project_id = #{project} AND " if !project.nil?
      w += "((payment_methods.flow = 3 OR payment_methods.flow = 2) AND payment_methods.cashier = TRUE)"
      supplier_payments = SupplierPayment.no_cash_desk_closing_yet(w)
      supplier_payment_totals = supplier_payments.select(payments_select).first
      # Other cash movements
      w = ''
      w = "cash_movements.organization_id = #{organization} AND " if !organization.nil?
      w = "cash_movements.company_id = #{company} AND " if !company.nil?
      w = "cash_movements.office_id = #{office} AND " if !office.nil?
      w += "(payment_methods.cashier = TRUE)"
      other_movements = CashMovement.no_cash_desk_closing_yet(w)
      other_movement_totals = other_movements.select(others_select).first
      # Payment & other totals
      amount_paid = supplier_payment_totals.totals
      invoices_paid = supplier_payment_totals.payments
      amount_others = other_movement_totals.totals
      quantity_others = other_movement_totals.movements

      cash_desk_closing = nil
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
          # Create cash desk closing
          closing_balance = opening_balance + amount_collected + amount_paid + amount_others
          cash_desk_closing = CashDeskClosing.new(organization_id: organization, company_id: company, office_id: office, project_id: project,
                                                  opening_balance: opening_balance, closing_balance: closing_balance, last_closing_id: last_closing,
                                                  amount_collected: amount_collected, invoices_collected: invoices_collected,
                                                  amount_paid: amount_paid, invoices_paid: invoices_paid,
                                                  amount_others: amount_others, quantity_others: quantity_others,
                                                  instruments_difference: instruments_difference, created_by: created_by)
          if cash_desk_closing.save
            #
            # Items
            #
            # Client payments (collections)
            client_payments.each do |cp|
              item = CashDeskClosingItem.new(cash_desk_closing_id: cash_desk_closing.id, client_payment_id: cp.id, amount: cp.amount, type_i: 'C', payment_method_id: cp.payment_method_id)
              if !item.save
                break
              end
            end # client_payments.each
            # Supplier payments
            supplier_payments.each do |sp|
              item = CashDeskClosingItem.new(cash_desk_closing_id: cash_desk_closing.id, supplier_payment_id: sp.id, amount: sp.amount * (-1), type_i: 'P', payment_method_id: sp.payment_method_id)
              if !item.save
                break
              end
            end # supplier_payments.each
            # Other movements
            other_movements.each do |om|
              if om.cash_desk_closing_item_type_i != 'N/A'
                item = CashDeskClosingItem.new(cash_desk_closing_id: cash_desk_closing.id, cash_movement_id: om.id, amount: om.amount, type_i: om.cash_desk_closing_item_type_i, payment_method_id: om.payment_method_id)
                if !item.save
                  break
                end
              end
            end # other_movements.each
            # Instruments
            currency_instrument_ids.each_with_index do |id, i|
              quantity = currency_instrument_quantities[i].to_i
              value = currency_instrument_values[i].to_d
              if currency_instrument_types[i].to_i > 2
                quantity = currency_instrument_values[i].to_i
                value = currency_instrument_quantities[i].to_d
              end
              amount = quantity * value
              instruments_difference += amount
              instrument = CashDeskClosingInstrument.new(cash_desk_closing_id: cash_desk_closing.id, currency_instrument_id: id.to_i, amount: amount, quantity: quantity)
              if !instrument.save
                break
              end
            end # currency_instrument_ids.each_with_index
            # Update CashDeskClosing.instruments_difference
            instruments_difference = closing_balance - instruments_difference
            cash_desk_closing.update_column(:instruments_difference, instruments_difference)
          end
        end # ActiveRecord::Base.transaction
        redirect_to client_payments_path + "#tab_cash", notice: (I18n.t('ag2_gest.cash_desk_closings.index.closing_ok') + " #{view_context.link_to I18n.t('ag2_gest.cash_desk_closings.index.click_to_print_closing'), close_cash_form_cash_desk_closing_path(cash_desk_closing, :format => :pdf), target: '_blank'}").html_safe
        # redirect_to client_payments_path, notice: "Caja cerrada sin incidencias."
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path + "#tab_cash", alert: I18n.t('ag2_gest.cash_desk_closings.index.closing_error')
      end # begin
    end

    def cash_to_pending
      # Set active_tab to use in view filters
      session[:active_tab] = "cash-tab"

      client_payments_ids = params[:cash_to_pending][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)
      invoices = []
      bills = []
      client_payments.each do |cp|
        # cp_instalment = nil
        invoice = cp.invoice
        bill = cp.bill
        if cp.instalment_id.blank?
          # invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
          invoice.update_column(:invoice_status_id, InvoiceStatus::PENDING)
        else
          # invoice.update_attributes(invoice_status_id: InvoiceStatus::FRACTIONATED)
          invoice.update_column(:invoice_status_id, InvoiceStatus::FRACTIONATED)
          # cp_instalment = cp.instalment
        end
        invoices << invoice
        # Sunspot.index! [invoice]
        if bill.invoice_status_id > invoice.invoice_status_id
          bill.update_column(:invoice_status_id, invoice.invoice_status_id)
          bills << bill
          # Sunspot.index! [invoice.bill]
        end
        cp.destroy
        # Sunspot.index! [cp_instalment.instalment_invoices] unless cp_instalment.nil?
      end
      Sunspot.index [bills, invoices]
      Sunspot.commit
      redirect_to client_payments_path + "#tab_cash", notice: "Factura/s y plazo/s devuelta/o/s a Pendientes sin incidencias."
    rescue
      redirect_to client_payments_path + "#tab_cash", alert: "¡Error!: Imposible devolver factura/s o plazo/s a Pendientes"
    end

    #
    # Others methods
    #
    def others
      # Set active_tab to use in view filters
      session[:active_tab] = "pendings-tab"

      invoices = Invoice.find_all_by_id(params[:client_payment_other][:invoices_ids].split(",")).sort_by {|a| a[:created_at]}
      amount = BigDecimal.new(params[:client_payment_other][:amount])
      payment_method = params[:client_payment_other][:payment_method_id]
      redirect_to client_payments_path + "#tab_pendings", alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method.blank?
      created_by = current_user.id if !current_user.nil?
      acu = amount
      # Receipt No.
      receipt_no = receipt_next_no(invoices.first.invoice_no[3..4]) || '0000000000'
      invoices.each do |i|
        if acu > 0
          if acu >= i.debt
            amount_paid = i.debt
            acu -= i.debt
            confirmation_date = Time.now
            invoice_status = InvoiceStatus::OTHER
          else
            amount_paid = acu
            acu = 0
            confirmation_date = nil
            invoice_status = InvoiceStatus::PENDING
          end
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::OTHERS, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method, client_id: i.bill.client_id, subscriber_id: i.bill.subscriber_id,
                               payment_date: Time.now, confirmation_date: nil, amount: amount_paid, instalment_id: nil,
                               client_bank_account_id: nil, charge_account_id: i.charge_account_id, created_by: created_by)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        else
          break
        end
      end
      redirect_to client_payments_path + "#tab_pendings"
    end

    def confirm_others
      # Set active_tab to use in view filters
      session[:active_tab] = "others-tab"

      client_payment_ids = params[:others_confirm][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payment_ids)
      client_payments.each do |cp|
        cp.update_attributes(confirmation_date: Time.now)
        cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::CHARGED)
      end
      redirect_to client_payments_path + "#tab_others", notice: "Otros cobros confirmados sin incidencias"
    end

    def others_to_pending
      # Set active_tab to use in view filters
      session[:active_tab] = "others-tab"

      client_payments_ids = params[:others_to_pending][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)
      invoices = []
      bills = []
      client_payments.each do |cp|
        # cp_instalment = nil
        invoice = cp.invoice
        bill = cp.bill
        if cp.instalment_id.blank?
          # cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
          invoice.update_column(:invoice_status_id, InvoiceStatus::PENDING)
        else
          # cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::FRACTIONATED)
          invoice.update_column(:invoice_status_id, InvoiceStatus::FRACTIONATED)
          # cp_instalment = cp.instalment
        end
        invoices << invoice
        # Sunspot.index! [invoice]
        if bill.invoice_status_id > invoice.invoice_status_id
          bill.update_column(:invoice_status_id, invoice.invoice_status_id)
          bills << bill
          # Sunspot.index! [invoice.bill]
        end
        cp.destroy
        # Sunspot.index! [cp_instalment.instalment_invoices] unless cp_instalment.nil?
      end
      Sunspot.index [bills, invoices]
      Sunspot.commit
      redirect_to client_payments_path + "#tab_others", notice: "Factura/s y plazo/s devuelta/o/s a Pendientes sin incidencias."
    rescue
      redirect_to client_payments_path + "#tab_others", alert: "¡Error!: Imposible devolver factura/s o plazo/s a Pendientes"
    end

    #
    # Bank methods
    #
    def banks
      # Set active_tab to use in view filters
      session[:active_tab] = "pendings-tab"

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
      invoices = Invoice.find_all_by_id(invoice_ids).sort_by {|a| a[:created_at]}
      # Payment type & status
      organization_id = invoices.first.organization_id
      invoice_status = InvoiceStatus::BANK
      payment_method_id = PaymentType.find(ClientPayment::BANK).payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end
      created_by = current_user.id if !current_user.nil?
      # Loop thru invoices and create payments
      invoices.each do |i|
        client_bank_account = i.client.active_bank_account
        if !client_bank_account.blank?
          client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: ClientPayment::BANK, bill_id: i.bill_id, invoice_id: i.id,
                               payment_method_id: payment_method_id, client_id: i.client.id, subscriber_id: i.subscriber.id,
                               payment_date: Time.now, confirmation_date: nil, amount: i.debt, instalment_id: nil,
                               client_bank_account_id: client_bank_account.id, charge_account_id: i.charge_account_id, created_by: created_by)
          if client_payment.save
            i.invoice_status_id = invoice_status
            i.save
          end
        end
      end # invoices.each
      redirect_to client_payments_path + "#tab_pendings", notice: "Factura/s domiciliada/s traspasadas a Banco."
    rescue
      redirect_to client_payments_path + "#tab_pendings", alert: "¡Error!: Imposible traspasar factura/s a Banco."
    end

    def bank_instalments(instalment_ids, receipt_no)
      # Set active_tab to use in view filters
      session[:active_tab] = "fractionated-tab"

      instalments = Instalment.where(id: instalment_ids)
      # Payment type & status
      organization_id = instalments.first.instalment_invoices.first.invoice.organization_id
      payment_method_id = PaymentType.find(ClientPayment::BANK).payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end
      created_by = current_user.id if !current_user.nil?

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
                                     client_bank_account_id: client_bank_account.id, charge_account_id: j.invoice.charge_account_id, created_by: created_by)
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
                redirect_to client_payments_path + "#tab_fractionated", alert: "¡Error! Imposible traspasar plazo/s a Banco." and return
                # break
              end
            end   # !client_bank_account.blank?
          end   # instalments.each
          redirect_to client_payments_path + "#tab_fractionated", notice: "Plazo/s domiciliado/s traspasados a Banco."
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path + "#tab_fractionated", alert: "¡Error! Imposible traspasar plazo/s a Banco." and return
      end # begin
    end

    def confirm_bank
      # Set active_tab to use in view filters
      session[:active_tab] = "banks-tab"

      client_payment_ids = params[:bank_confirm][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payment_ids)
      client_payments.each do |cp|
        cp.update_attributes(confirmation_date: Time.now)
        cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::CHARGED)
      end
      redirect_to client_payments_path + "#tab_banks", notice: "Cobros domicilados confirmados sin incidencias"
    end

    def bank_to_pending
      # Set active_tab to use in view filters
      session[:active_tab] = "banks-tab"

      client_payments_ids = params[:bank_to_pending][:client_payments_ids].split(",")
      client_payments = ClientPayment.where(id: client_payments_ids)
      invoices = []
      bills = []
      client_payments.each do |cp|
        # cp_instalment = nil
        invoice = cp.invoice
        bill = cp.bill
        if cp.instalment_id.blank?
          # cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
          invoice.update_column(:invoice_status_id, InvoiceStatus::PENDING)
        else
          # cp.invoice.update_attributes(invoice_status_id: InvoiceStatus::FRACTIONATED)
          invoice.update_column(:invoice_status_id, InvoiceStatus::FRACTIONATED)
          # cp_instalment = cp.instalment
        end
        invoices << invoice
        # Sunspot.index! [invoice]
        if bill.invoice_status_id > invoice.invoice_status_id
          bill.update_column(:invoice_status_id, invoice.invoice_status_id)
          bills << bill
          # Sunspot.index! [invoice.bill]
        end
        cp.destroy
        # Sunspot.index! [cp_instalment.instalment_invoices] unless cp_instalment.nil?
      end
      Sunspot.index [bills, invoices]
      Sunspot.commit
      redirect_to client_payments_path + "#tab_banks", notice: "Factura/s y plazo/s devuelta/o/s a Pendientes sin incidencias."
    rescue
      redirect_to client_payments_path + "#tab_banks", alert: "¡Error!: Imposible devolver factura/s o plazo/s a Pendientes"
    end

    # Generates & Export SEPA XML file (order, direct debit)
    def bank_to_order
      # Set active_tab to use in view filters
      session[:active_tab] = "banks-tab"

      client_payments_ids = params[:bank_to_order][:client_payments_ids].split(",")
      by_invoice = params[:bank_to_order][:by_invoice] == "1" ? true : false
      # redirect_to client_payments_path + "#tab_banks", alert: by_invoice and return
      bank_account_id = params[:bank_to_order][:bank_account_id]
      scheme_type_id = params[:bank_to_order][:scheme_type_id]
      presentation_date = params[:bank_to_order][:presentation_date]
      charge_date = params[:bank_to_order][:charge_date]

      # client_payments = ClientPayment.where(id: client_payments_ids)
      client_payments = by_invoice == true ? ClientPayment.where(id: client_payments_ids) : ClientPayment.by_bill_for_bank_order(client_payments_ids)
      bank_account = CompanyBankAccount.find(bank_account_id)
      scheme_type = SepaSchemeType.find(scheme_type_id)

      # Process only if there is unconfirmed payments
      if !client_payments.count.blank? && !bank_account.blank? && !scheme_type.blank?
        time_now = Time.new

        # SEPA Creditor Id
        creditor_id = bank_account.sepa_id
        if creditor_id.blank? || bank_account.bank_suffix.blank? || bank_account.holder_fiscal_id.blank?
          redirect_to client_payments_path + "#tab_banks", alert: "¡Error!: Imposible remesar factura/s o plazo/s: Datos bancarios incorrectos." and return
        end

        # Instantiate class
        sepa = Ag2Gest::SepaOrder.new(client_payments, by_invoice)

        # Initialize class attributes
        sepa.identificacion_fichero = "PRE" + time_now.strftime("%Y%m%d%H%M%S%L") + "00" +
                                      bank_account.bank_suffix.strip + bank_account.holder_fiscal_id.strip
        sepa.fecha_hora_confeccion = time_now.strftime("%Y-%m-%d") + "T" + time_now.strftime("%H:%M:%S")
        # sepa.numero_total_adeudos = client_payments.count
        # sepa..to_d = en_formatted_number_without_delimiter(client_payments.sum('amount+surcharge'), 2)
        sepa.nombre_presentador = bank_account.sanitized_company_name
        sepa.identificacion_presentador = creditor_id
        sepa.tipo_esquema = scheme_type.name
        sepa.identificacion_info_pago = creditor_id + time_now.strftime("%Y%m%d%H%M%S%L") + "00"
        sepa.fecha_cobro = charge_date.to_date.strftime("%Y-%m-%d")
        sepa.cuenta_acreedor = bank_account.right_iban
        sepa.time_now = time_now

        # Generate XML object
        xml = sepa.write_xml
        # xml = by_invoice == true ? sepa.write_xml : sepa.write_xml_by_bill

        # Write & Upload XML file
        file_name = sepa.identificacion_fichero + ".xml"
        file_path = "/uploads/" + sepa.identificacion_fichero + ".xml"
        upload_xml_file(file_name, xml)

        # Notify successful ending
        # redirect_to client_payments_path, notice: "Factura/s y plazo/s remesados sin incidencias."
        # redirect_to client_payments_path + "#tab_banks?active_tab=banks_tab",
        redirect_to client_payments_path + "#tab_banks",
                    notice: (I18n.t('ag2_gest.client_payments.index.bank_to_order_ok') +
                            " #{view_context.link_to I18n.t('ag2_gest.bills_to_files.index.go_to_target', var: file_name), file_path, download: file_name}"
                            ).html_safe
      end

    rescue
      redirect_to client_payments_path + "#tab_banks", alert: I18n.t('ag2_gest.client_payments.index.bank_to_order_error')
    end

    def download_bank_to_order_file(file_name)
      file_to_download = Rails.root.join('public', 'uploads', file_name)
      send_file file_to_download
    end

    # Import SEPA XML file (return, rejections)
    def bank_from_return
      # Set active_tab to use in view filters
      session[:active_tab] = "banks-tab"

      file_to_process = params[:bank_from_return][:file_to_process]
      file_content = params[:bank_from_return][:file_content]
      file_name = params[:bank_from_return][:file_name]

      # Instantiate class
      # sepa = Ag2Gest::SepaReturn.new(file_to_process)
      sepa = Ag2Gest::SepaReturn.new(file_content)
      # Read XML object
      sepa.read_xml
      remesa = sepa.remesa

      # Check:
      # Has not been proccessed previously
      # Belongs to current company & bank suffix
      # redirect_to client_payments_path + "#tab_banks", alert: sepa.fecha_hora_confeccion and return
      bank_account = CompanyBankAccount.by_fiscal_id_and_suffix(sepa.nif, sepa.sufijo)
      if bank_account.nil? || bank_account.empty?
        # Can't go on if bank account doesn't exist
        redirect_to client_payments_path + "#tab_banks", alert: "¡Error!: Imposible procesar devoluciones: No se ha encontrado cuenta empresa con los datos del fichero indicado." and return
      end
      if session[:company] != '0' && bank_account.first.company_id != session[:company].to_i
        # Can't go on if it's not the right bank account for current company
        redirect_to client_payments_path + "#tab_banks", alert: "¡Error!: Imposible procesar devoluciones: El fichero que intentas procesar pertenece a otra empresa o cuenta." and return
      end
      processed_file = ProcessedFile.by_name_and_type(file_name, ProcessedFileType::BANK_RETURN).first rescue nil
      if !processed_file.blank?
        # Can't go on because file has already been processed
        created_at = formatted_timestamp(processed_file.created_at)
        created_by = User.find(processed_file.created_by).email rescue 'N/A'
        warning = "¡Advertencia!: El fichero que intentas procesar ya ha sido procesado por " + created_by + " el " + created_at + "."
        redirect_to client_payments_path + "#tab_banks", alert: warning and return
      end
      # Search payment method for returns
      organization_id = bank_account.first.company.organization_id
      payment_method_id = PaymentType.find(ClientPayment::BANK).return_payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end
      created_by = !current_user.nil? ? current_user.id : nil

      # Loop thru return/reject items
      sepa.lista_devoluciones.each do |i|
        # Search original client payment
        begin
          original_client_payment = ClientPayment.find(i[:client_payment_id])
        rescue  # sufijo based on OrgnlMsgId
          original_client_payment = ClientPayment.search_by_old_no_from_return(i[:client_payment_id].to_s)
          remesa = sepa.remesa_old
        end
        # original_client_payment = ClientPayment.find(i[:client_payment_id]) rescue ClientPayment.search_by_old_no_from_return(i[:client_payment_id].to_s)
        sepa_return_code = SepaReturnCode.find_by_code(i[:codigo_rechazo]).id rescue nil
        if !original_client_payment.nil?
          # If original payment is not confirmed, set confirmation date
          original_client_payment.update_attributes(confirmation_date: Time.now) if original_client_payment.confirmation_date.blank?
          # Add rejections to client payments
          cp = ClientPayment.new(receipt_no: original_client_payment.receipt_no,
                                 payment_type: ClientPayment::BANK,
                                 bill_id: original_client_payment.bill_id,
                                 invoice_id: original_client_payment.invoice_id,
                                 payment_method_id: payment_method_id,
                                 client_id: original_client_payment.client_id,
                                 subscriber_id: original_client_payment.subscriber_id,
                                 payment_date: sepa.fecha_devolucion,
                                 confirmation_date: Time.now,
                                 amount: i[:importe_adeudo],
                                 instalment_id: original_client_payment.instalment_id,
                                 client_bank_account_id: original_client_payment.client_bank_account_id,
                                 charge_account_id: original_client_payment.charge_account_id,
                                 created_by: created_by,
                                 sepa_return_code_id: sepa_return_code)
          if cp.save
            # Set related invoice status to pending
            original_client_payment.invoice.update_attributes(invoice_status_id: InvoiceStatus::PENDING)
          end
        end
      end # sepa.lista_devoluciones.each

      notice = sepa.lista_devoluciones.size.to_s + " Devoluciones procesadas correctamente (Remesa: " + remesa + "=" + sepa.numero_total_adeudos + "x" + formatted_number(sepa.importe_total.to_d, 2) + ")"

      # Catalogs the processed file
      processed_file = ProcessedFile.new(filename: file_name,
                                         processed_file_type_id: ProcessedFileType::BANK_RETURN,
                                         flow: ProcessedFile::INPUT,
                                         created_by: created_by)
      if !processed_file.save
        redirect_to client_payments_path + "#tab_banks", alert: "¡Advertencia! #{notice}, pero el fichero no ha podido ser catalogado." and return
      end

      # Notify successful ending
      notice = notice + "."
      redirect_to client_payments_path + "#tab_banks", notice: notice

    rescue
      redirect_to client_payments_path + "#tab_banks", alert: "¡Error!: Imposible procesar devoluciones."
    end

    # Import Counter text file (bank counter operations)
    # pending
    def bank_from_counter
      # Set active_tab to use in view filters
      session[:active_tab] = "banks-tab"

      file_to_process = params[:bank_from_counter][:file_to_process]
      file_content = params[:bank_from_counter][:file_content]
      file_name = params[:bank_from_counter][:file_name]

      # Instantiate class
      # sepa = Ag2Gest::SepaCounter.new(file_to_process)
      sepa = Ag2Gest::SepaCounter.new(file_content)
      # Read TXT object
      sepa.read_txt

      # Check:
      # Has not been proccessed previously
      # Belongs to current company & bank suffix
      # redirect_to client_payments_path + "#tab_banks", alert: sepa.nif + ' - ' + sepa.sufijo and return
      bank_account = CompanyBankAccount.like_fiscal_id_and_suffix(sepa.nif, sepa.sufijo)
      if bank_account.nil? || bank_account.empty?
        # Can't go on if bank account doesn't exist
        redirect_to client_payments_path + "#tab_banks", alert: "¡Error! Imposible procesar cobros ventanilla: No se ha encontrado cuenta empresa con los datos del fichero indicado." and return
      end
      if session[:company] != '0' && bank_account.first.company_id != session[:company].to_i
        # Can't go on if it's not the right bank account for current company
        redirect_to client_payments_path + "#tab_banks", alert: "¡Error! Imposible procesar cobros ventanilla: El fichero que intentas procesar pertenece a otra empresa o cuenta." and return
      end
      processed_file = ProcessedFile.by_name_and_type(file_name, ProcessedFileType::BANK_COUNTER).first rescue nil
      if !processed_file.blank?
        # Can't go on because file has already been processed
        created_at = formatted_timestamp(processed_file.created_at)
        created_by = User.find(processed_file.created_by).email rescue 'N/A'
        warning = "¡Advertencia! El fichero que intentas procesar ya ha sido procesado por " + created_by + " el " + created_at + "."
        redirect_to client_payments_path + "#tab_banks", alert: warning and return
      end
      # Search payment method for counter
      organization_id = bank_account.first.company.organization_id
      payment_method_id = PaymentType.find(ClientPayment::COUNTER).payment_method_id rescue collection_payment_methods(organization_id).first.id
      if payment_method_id.nil?
        payment_method_id = collection_payment_methods(organization_id).first.id
      end
      # Created by
      created_by = !current_user.nil? ? current_user.id : nil
      # redirect_to client_payments_path + "#tab_banks", alert: "No procesado." and return

      # Loop thru counter items
      sepa.lista_cobros.each do |c|
        # Search original bill
        bill = Bill.find(c[:bill_id]) rescue Bill.search_by_old_no_from_counter(c[:bill_id].to_s)
        if !bill.nil?
          receipt_no = receipt_next_no(bill.invoices.first.invoice_no[3..4]) || '0000000000'
          # Add to client payments
          bill.invoices.each do |i|
            cp = ClientPayment.new(receipt_no: receipt_no,
                                   payment_type: ClientPayment::COUNTER,
                                   bill_id: bill.id,
                                   invoice_id: i.id,
                                   payment_method_id: payment_method_id,
                                   client_id: bill.client_id,
                                   subscriber_id: bill.subscriber_id,
                                   payment_date: c[:date],
                                   confirmation_date: Time.now,
                                   amount: i.debt,
                                   instalment_id: nil,
                                   client_bank_account_id: nil,
                                   charge_account_id: i.charge_account_id,
                                   created_by: created_by)
            if cp.save
              # Set related invoice status to charged
              i.update_attributes(invoice_status_id: InvoiceStatus::CHARGED)
            end
          end # bill.invoices.each
        end # !bill.nil?
      end # sepa.lista_cobros.each

      notice = sepa.total_bills.to_s + " Cobros por ventanilla procesados correctamente x " + formatted_number(sepa.total_amount, 2)

      # Catalogs the processed file
      processed_file = ProcessedFile.new(filename: file_name,
                                         processed_file_type_id: ProcessedFileType::BANK_COUNTER,
                                         flow: ProcessedFile::INPUT,
                                         created_by: created_by)
      if !processed_file.save
        redirect_to client_payments_path + "#tab_banks", alert: "¡Advertencia! #{notice}, pero el fichero no ha podido ser catalogado." and return
      end

      # Notify successful ending
      notice = notice + "."
      redirect_to client_payments_path + "#tab_banks", notice: notice

    rescue
      redirect_to client_payments_path + "#tab_banks", alert: "¡Error! Imposible procesar cobros ventanilla."
    end

    #
    # Instalments methods
    #
    # Must fractionate invoices from the same client!!
    def fractionate
      # Set active_tab to use in view filters
      session[:active_tab] = "pendings-tab"

      # Params
      invoice_ids = params[:instalment][:invoices_ids].split(",")
      number_quotas = params[:instalment][:number_inst].to_i
      amount_first = params[:instalment][:amount_first].to_d
      charge = params[:instalment][:charge].to_d
      payment_method_id = params[:instalment][:payment_method_id]
      redirect_to client_payments_path + "#tab_pendings", alert: I18n.t("ag2_gest.client_payments.generate_error_payment") and return if payment_method_id.blank?
      created_by = current_user.id if !current_user.nil?

      # Check that all invoices are from the same client
      clients = Client.joins(bills: :invoices).where('invoices.id IN (?)', invoice_ids).select('clients.id').group('clients.id').to_a
      if clients.count > 1
        redirect_to client_payments_path + "#tab_pendings", alert: "Imposible aplazar facturas de varios clientes a la vez." and return
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
              if i > invoices.size
                break
              end
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
        end # ActiveRecord::Base.transaction
        redirect_to client_payments_path + "#tab_pendings", notice: I18n.t('ag2_gest.client_payments.fractionate_ok', var: instalment_no)
      rescue ActiveRecord::RecordInvalid
        redirect_to client_payments_path + "#tab_pendings", alert: I18n.t(:transaction_error, var: "fractionate") and return
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

      # Set per_page to use in cash, bank, deferrals & others
      per_page_cash = params[:per_page_cash].blank? ? 10 : params[:per_page_cash]
      per_page_bank = params[:per_page_bank].blank? ? 10 : params[:per_page_bank]
      per_page_deferrals = params[:per_page_deferrals].blank? ? 10 : params[:per_page_deferrals]
      per_page_others = params[:per_page_others].blank? ? 10 : params[:per_page_others]

      # Set active_tab to use in searches
      # if params[:active_tab] content finished with !, remove filter
      active_tab = ''
      if params[:active_tab]
        active_tab = params[:active_tab]
      end
      puts ">>>>>>>" + active_tab

      no = params[:No]
      project = params[:Project]
      period = params[:Period]
      # client_code = params[:ClientCode]
      # client_fiscal = params[:ClientFiscal]
      # client_name = params[:Client]
      client = params[:Client]
      # subscriber_code = params[:SubscriberCode]
      # subscriber_fiscal = params[:SubscriberFiscal]
      # subscriber_name = params[:Subscriber]
      subscriber = params[:Subscriber]
      street_name = params[:StreetName]
      bank_account = params[:BankAccount] == t(:yes_on) ? true : false
      bank = params[:Bank]
      bank_order = params[:BankOrder]
      user = params[:User]

      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @project = !project.blank? ? Project.find(project).full_name : " "
      @period = !period.blank? ? BillingPeriod.find(period).to_label : " "
      @user = !user.blank? ? User.find(user).to_label : " "
      @client = !client.blank? ? Client.find(client).to_label : " "
      @subscriber = !subscriber.blank? ? Subscriber.find(subscriber).to_label : " "
      # @address = !street_name.blank? ? Subscriber.find(street_name).supply_address : " "
      # DO NOT USE @address = !street_name.blank? ? SubscriberSupplyAddress.find(street_name).supply_address : " "
      @have_bank_account = have_bank_account_array
      @payment_methods = payment_methods_dropdown
      @cashier_payment_methods = cashier_payment_methods_dropdown
      @no_cashier_payment_methods = no_cashier_payment_methods_dropdown
      @bank_accounts = bank_accounts_dropdown
      @scheme_types = SepaSchemeType.by_id

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name
      current_projects = current_projects_ids

      # Setup Client for search
      # client = !client.blank? ? inverse_client_search(client) : client
      # client_code = !client_code.blank? ? inverse_client_code_search(client_code) : []
      # client_fiscal = !client_fiscal.blank? ? inverse_client_fiscal_search(client_fiscal) : []
      # client_name = !client_name.blank? ? inverse_client_name_search(client_name) : []
      # c = (client_code + client_fiscal + client_name).uniq

      # Setup Subscriber for search
      # subscriber = !subscriber.blank? ? inverse_subscriber_search(subscriber) : subscriber
      # subscriber_code = !subscriber_code.blank? ? inverse_subscriber_code_search(subscriber_code) : []
      # subscriber_fiscal = !subscriber_fiscal.blank? ? inverse_subscriber_fiscal_search(subscriber_fiscal) : []
      # subscriber_name = !subscriber_name.blank? ? inverse_subscriber_name_search(subscriber_name) : []
      # s = (subscriber_code + subscriber_fiscal + subscriber_name).uniq

      # Initialize datasets
      # if no.blank? && project.blank? && period.blank? && client_name.blank? && subscriber_name.blank? &&
      #    street_name.blank? && bank_account.blank? && bank.blank? && bank_order.blank?  && user.blank? &&
      #    client_code.blank? && client_fiscal.blank? && subscriber_code.blank? && subscriber_fiscal.blank?
      if no.blank? && project.blank? && period.blank? && client.blank? && subscriber.blank? &&
         street_name.blank? && bank_account.blank? && bank.blank? && bank_order.blank?  && user.blank?
        # No query received, or filters has been removed: Return no results, except cash, bank & others
        @bills_pending = Bill.search { with :invoice_status_id, -1 }.results
        @bills_charged = Bill.search { with :invoice_status_id, -1 }.results
        @instalment_invoices = InstalmentInvoice.search { with :client_id, -1 }.results
        search_cash = cash_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        search_bank = bank_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user, bank_order, per_page_bank)
        search_others = others_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        @client_payments_cash = search_cash.results
        @client_payments_bank = search_bank.results
        @client_payments_others = search_others.results
      else
        # Valid query received: Return found results
        # Setup Sunspot searches (cash, bank & others should have data always)
        case active_tab
        when 'pendings-tab', 'cash-tab', 'banks-tab', 'others-tab', 'fractionated-tab'
          search_pending = pendings_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_cash = cash_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_bank = bank_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user, bank_order, per_page_bank)
          search_instalment = instalment_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_others = others_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        when 'charged-tab'
          search_charged = charged_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        # when 'cash-tab'
        #   search_cash = cash_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        # when 'banks-tab'
        #   search_bank = bank_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user, bank_order, per_page_bank)
        # when 'others-tab'
        #   search_others = others_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        # when 'fractionated-tab'
        #   search_instalment = instalment_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        else  # No active tab, or remove filters button has been clicked
          search_pending = pendings_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_charged = charged_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_cash = cash_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_bank = bank_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user, bank_order, per_page_bank)
          search_others = others_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
          search_instalment = instalment_search(current_projects, no, project, client, subscriber, street_name, bank_account, period, user)
        end
        @bills_pending = search_pending.results rescue Bill.search { with :invoice_status_id, -1 }.results
        @bills_charged = search_charged.results rescue Bill.search { with :invoice_status_id, -1 }.results
        @client_payments_others = search_others.results rescue ClientPayment.search { with :payment_type, -1 }.results
        @instalment_invoices = search_instalment.results rescue InstalmentInvoice.search { with :client_id, -1 }.results
        @client_payments_cash = search_cash.results rescue ClientPayment.search { with :payment_type, -1 }.results
        @client_payments_bank = search_bank.results rescue ClientPayment.search { with :payment_type, -1 }.results
      end

      # Set active_tab to use in view filters
      params[:active_tab] = active_tab.blank? ? 'pendings-tab' : active_tab.chomp('!')

      # Initialize totals
      @pending_totals = { bills: @bills_pending.size, debts: @bills_pending.sum(&:debt) }
      @charged_totals = { bills: @bills_charged.size, totals: @bills_charged.sum(&:total) }
      @cash_totals = { payments: @client_payments_cash.size, totals: @client_payments_cash.sum(&:amount) }
      @bank_totals = { payments: @client_payments_bank.size, totals: @client_payments_bank.sum(&:amount) }
      @others_totals = { payments: @client_payments_others.size, totals: @client_payments_others.sum(&:amount) }
      @instalment_invoices_totals = { payments: @instalment_invoices.size, totals: @instalment_invoices.sum(&:amount) }

      # Instalments
      instalment_ids = @instalment_invoices.map(&:instalment_id).uniq
      @instalments = Instalment.with_these_ids(instalment_ids)
      @instalments_totals = { payments: @instalments.size, totals: @instalments.sum(&:amount) }
      plans_select = 'count(id) as plans'
      plan_ids = @instalments.map(&:instalment_plan_id).uniq
      @plans_totals = InstalmentPlan.where(id: plan_ids).select(plans_select).first
      @instalments = @instalments.paginate(:page => params[:instalments_page], :per_page => per_page || 10)

      # bills_select = 'count(bills.id) as bills, coalesce(sum(invoices.totals),0) as totals'
      # pending_bills_select = 'count(bills.id) as bills, coalesce(sum(invoice_current_debts.debt),0) as debts'
      # collections_select = 'count(id) as payments, coalesce(sum(amount),0) as totals'
      # plans_select = 'count(id) as plans'
      # payments_select = 'count(supplier_payments.id) as payments, coalesce(sum(supplier_payments.amount),0)*(-1) as totals'
      # others_select = 'count(cash_movements.id) as movements, coalesce(sum(cash_movements.amount),0) as totals'

      # pending_ids = @bills_pending.map(&:id)
      # charged_ids = @bills_charged.map(&:id)
      # cash_ids = @client_payments_cash.map(&:id)
      # bank_ids = @client_payments_bank.map(&:id)
      # others_ids = @client_payments_others.map(&:id)
      # instalment_invoices_ids = @instalment_invoices.map(&:id)
      # instalment_ids = @instalment_invoices.map(&:instalment_id).uniq

      # @pending_totals = Bill.select(pending_bills_select).joins(:invoice_current_debts).where(id: pending_ids).first
      # @charged_totals = Bill.select(bills_select).joins(:invoices).where(id: charged_ids).first
      # @cash_totals = ClientPayment.select(collections_select).where(id: cash_ids).first
      # @bank_totals = ClientPayment.select(collections_select).where(id: bank_ids).first
      # @others_totals = ClientPayment.select(collections_select).where(id: others_ids).first
      # @instalment_invoices_totals = InstalmentInvoice.select(collections_select).where(id: instalment_invoices_ids).first

      # @instalments = Instalment.with_these_ids(instalment_ids).paginate(:page => params[:page], :per_page => per_page || 10)
      # @instalments_totals = @instalments.select(collections_select).first
      # plan_ids = @instalments.map(&:instalment_plan_id).uniq
      # @plans_totals = InstalmentPlan.where(id: plan_ids).select(plans_select).first

      # Supplier payments
      payments_select = 'count(supplier_payments.id) as payments, coalesce(sum(supplier_payments.amount),0)*(-1) as totals'
      w = ''
      w = "supplier_payments.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
      w = "supplier_invoices.company_id = #{session[:company]} AND " if session[:company] != '0'
      w = "projects.office_id = #{session[:office]} AND " if session[:office] != '0'
      w += "((payment_methods.flow = 3 OR payment_methods.flow = 2) AND payment_methods.cashier = TRUE)"
      @supplier_payments = SupplierPayment.no_cash_desk_closing_yet(w).select(payments_select).first

      # Other cash movements
      others_select = 'count(cash_movements.id) as movements, coalesce(sum(cash_movements.amount),0) as totals'
      w = ''
      w = "cash_movements.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
      w = "cash_movements.company_id = #{session[:company]} AND " if session[:company] != '0'
      w = "cash_movements.office_id = #{session[:office]} AND " if session[:office] != '0'
      w += "(payment_methods.cashier = TRUE)"
      @other_cash = CashMovement.no_cash_desk_closing_yet(w).select(others_select).first

      # Open last cash desk closing
      @last_cash_desk_closing = open_cash
      @opening_balance = @last_cash_desk_closing.closing_balance rescue 0
      @closing_balance = @opening_balance + @cash_totals[:totals] + @supplier_payments.totals + @other_cash.totals

      # Currencies & instruments
      @currency = Currency.find_by_alphabetic_code('EUR')
      @currency_instruments = CurrencyInstrument.having_currency(@currency.id) rescue CurrencyInstrument.none

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: {bills_pending: @bills_pending, bills_charged: @bills_charged, client_payments_cash: @client_payments_cash, client_payments_bank: @client_payments_bank, client_payments_others: @client_payments_others, instalments: @instalments } }
        format.js
      end
    end

    ##################################
    # Begin Region: Sunspot searches #
    ##################################
    def pendings_search(current_projects, no, project, c, s, street_name, bank_account, period, user)
      Bill.search do
        with(:invoice_status_id, 0..98)
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        # Billing period
        if !period.blank?
          with :billing_period_id, period
        end
        # Created by (user)
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(Bill).include = [{client: :client_bank_accounts}, :subscriber, :invoice_status, :payment_method, {invoices: [:invoice_type, :invoice_operation, {invoice_items: :tax_type}]}, :instalments]
        order_by :sort_no, :asc
        paginate :page => params[:bills_pending_page] || 1, :per_page => 10
      end
    end

    def charged_search(current_projects, no, project, c, s, street_name, bank_account, period, user)
      Bill.search do
        with :invoice_status_id, InvoiceStatus::CHARGED
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(Bill).include = [{client: :client_bank_accounts}, :subscriber, :invoice_status, :payment_method, {invoices: [:invoice_type, :invoice_operation, {invoice_items: :tax_type}]}]
        order_by :sort_no, :asc
        paginate :page => params[:bills_charged_page] || 1, :per_page => 10
      end
    end

    def cash_search(current_projects, no, project, c, s, street_name, bank_account, period, user, per_page=10)
      ClientPayment.search do
        with :payment_type, ClientPayment::CASH
        with :confirmation_date, nil
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:client_payments_cash_page] || 1, :per_page => per_page
      end
    end

    def bank_search(current_projects, no, project, c, s, street_name, bank_account, period, user, bank_order, per_page=10)
      ClientPayment.search do
        with :payment_type, ClientPayment::BANK
        with :confirmation_date, nil
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !bank_order.blank?
          with :receipt_no, bank_order
        end
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:client_payments_bank_page] || 1, :per_page => per_page
      end
    end

    def others_search(current_projects, no, project, c, s, street_name, bank_account, period, user, per_page=10)
      ClientPayment.search do
        # with(:invoice_status_id, 0..98)
        with :payment_type, ClientPayment::OTHERS
        with :confirmation_date, nil
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(ClientPayment).include = [:bill, :client, :payment_method, :instalment, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:client_payments_others_page] || 1, :per_page => per_page
      end
    end

    def instalment_search(current_projects, no, project, c, s, street_name, bank_account, period, user, per_page=10)
      InstalmentInvoice.search do
        with :client_payment, nil
        if !current_projects.blank?
          with :project_id, current_projects
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        # Client
        # if !client.blank?
        #   if client.class == Array
        #     with :client_code_name_fiscal, client
        #   else
        #     with(:client_code_name_fiscal).starting_with(client)
        #   end
        # end
        # if !c.empty?
        #   with :client_ids, c
        # end
        if !c.blank?
          with :client_id, c
        end
        # Subscriber
        # if !subscriber.blank?
        #   if subscriber.class == Array
        #     with :subscriber_code_name_fiscal, subscriber
        #   else
        #     with(:subscriber_code_name_fiscal).starting_with(subscriber)
        #   end
        # end
        # if !s.empty?
        #   with :subscriber_ids, s
        # end
        if !s.blank?
          with :subscriber_id, s
        end
        # Supply address
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !street_name.blank?
        #   with :supply_address, street_name
        # end
        # if !street_name.blank?
        #   with :subscriber_id, street_name
        # end
        # Have active bank account?
        if !bank_account.blank?
          with :bank_account, bank_account
        end
        if !period.blank?
          with :billing_period_id, period
        end
        if !user.blank?
          with :created_by, user
        end
        data_accessor_for(InstalmentInvoice).include = [:bill, {instalment: {instalment_plan: [:client, :subscriber, :payment_method]}}, {invoice: {invoice_items: :tax_type}}]
        order_by :sort_no, :asc
        paginate :page => params[:instalments_page] || 1, :per_page => per_page
      end
    end
    ################################
    # End Region: Sunspot searches #
    ################################

    def payment_receipt
      @payment = ClientPayment.find(params[:id])
      @payment_receipt = ClientPayment.where(receipt_no: @payment.receipt_no)
      @payment_receipt_bill = ClientPayment.where(receipt_no: @payment.receipt_no).group(:bill_id)
      @payment_subscribers = ClientPayment.where(receipt_no: @payment.receipt_no).group(:subscriber_id)
      title = t("activerecord.models.client_payment.one")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@payment.receipt_no}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

     # client payment report
    def client_payment_view_report
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
      Invoice.where('invoice_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.invoice_no
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

    def inverse_client_code_search(client)
      no = setup_no(client)
      w = "client_code LIKE '#{no}'"
      searched_clients(w)
    end

    def inverse_client_fiscal_search(client)
      no = setup_no(client)
      w = "fiscal_id LIKE '#{no}'"
      searched_clients(w)
    end

    def inverse_client_name_search(client)
      no = setup_no(client)
      w = "(last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}')"
      searched_clients(w)
    end

    def searched_clients(w)
      Client.select(:id).where(w).first(1000).map(&:id)
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

    def inverse_subscriber_code_search(subscriber)
      no = setup_no(subscriber)
      w = "subscriber_code LIKE '#{no}'"
      searched_subscribers(w)
    end

    def inverse_subscriber_fiscal_search(subscriber)
      no = setup_no(subscriber)
      w = "fiscal_id LIKE '#{no}'"
      searched_subscribers(w)
    end

    def inverse_subscriber_name_search(subscriber)
      no = setup_no(subscriber)
      w = "(last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}')"
      searched_subscribers(w)
    end

    def searched_subscribers(w)
      Subscriber.select(:id).where(w).first(1000).map(&:id)
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

    def bank_accounts_dropdown
      session[:company] != '0' ? CompanyBankAccount.active_by_company(session[:company].to_i) : CompanyBankAccount.active
    end

    # Keeps filter state
    def manage_filter_state
      # active tab
      if params[:active_tab]
        session[:active_tab] = params[:active_tab]
      elsif session[:active_tab]
        params[:active_tab] = session[:active_tab]
      end
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
      # period
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
      # client
      if params[:Client]
        session[:Client] = params[:Client]
      elsif session[:Client]
        params[:Client] = session[:Client]
      end
      # client code
      if params[:ClientCode]
        session[:ClientCode] = params[:ClientCode]
      elsif session[:ClientCode]
        params[:ClientCode] = session[:ClientCode]
      end
      # client fiscal
      if params[:ClientFiscal]
        session[:ClientFiscal] = params[:ClientFiscal]
      elsif session[:ClientFiscal]
        params[:ClientFiscal] = session[:ClientFiscal]
      end
      # subscriber
      if params[:Subscriber]
        session[:Subscriber] = params[:Subscriber]
      elsif session[:Subscriber]
        params[:Subscriber] = session[:Subscriber]
      end
      # subscriber
      if params[:SubscriberCode]
        session[:SubscriberCode] = params[:SubscriberCode]
      elsif session[:SubscriberCode]
        params[:SubscriberCode] = session[:SubscriberCode]
      end
      # subscriber
      if params[:SubscriberFiscal]
        session[:SubscriberFiscal] = params[:SubscriberFiscal]
      elsif session[:SubscriberFiscal]
        params[:SubscriberFiscal] = session[:SubscriberFiscal]
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
      # bank
      if params[:Bank]
        session[:Bank] = params[:Bank]
      elsif session[:Bank]
        params[:Bank] = session[:Bank]
      end
      # bank_order
      if params[:BankOrder]
        session[:BankOrder] = params[:BankOrder]
      elsif session[:BankOrder]
        params[:BankOrder] = session[:BankOrder]
      end
      # user
      if params[:User]
        session[:User] = params[:User]
      elsif session[:User]
        params[:User] = session[:User]
      end
    end

    def cp_remove_filters
      params[:No] = ""
      params[:Project] = ""
      params[:Period] = ""
      params[:Client] = ""
      params[:ClientCode] = ""
      params[:ClientFiscal] = ""
      params[:Subscriber] = ""
      params[:SubscriberCode] = ""
      params[:subscriber_code_name_fiscal] = ""
      params[:StreetName] = ""
      params[:BankAccount] = ""
      params[:Bank] = ""
      params[:BankOrder] = ""
      params[:User] = ""
      return " "
    end

    def cp_restore_filters
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Period] = session[:Period]
      params[:Client] = session[:Client]
      params[:ClientCode] = session[:ClientCode]
      params[:ClientFiscal] = session[:ClientFiscal]
      params[:Subscriber] = session[:Subscriber]
      params[:SubscriberCode] = session[:SubscriberCode]
      params[:SubscriberFiscal] = session[:SubscriberFiscal]
      params[:StreetName] = session[:StreetName]
      params[:BankAccount] = session[:BankAccount]
      params[:Bank] = session[:Bank]
      params[:BankOrder] = session[:BankOrder]
      params[:User] = session[:User]
    end
  end
end
