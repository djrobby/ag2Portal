require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ClientPaymentsController < ApplicationController

    def cash_others
      invoices = Invoice.find_all_by_id(params[:client_payment][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      amount = params[:client_payment][:amount].to_f
      payment_method = params[:client_payment][:payment_method_id]
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
      redirect_to client_payments_path, notice: "Vuleta de " + acu.to_s
    end

    def banks
      invoices = Invoice.find_all_by_id(params[:client_payment_bank][:invoices_ids].split(",")).sort {|a, b| b[:created_at] <=> a[:created_at]}
      receipt_no = params[:client_payment_bank][:receipt_no]
      invoice_status = InvoiceStatus::BANK
      invoices.each do |i|
        client_payment = ClientPayment.new(receipt_no: receipt_no, payment_type: 2, bill_id: i.bill_id, invoice_id: i.id,
                             payment_method_id: nil, client_id: i.bill.subscriber.client_id, subscriber_id: i.bill.subscriber_id,
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
      number_quotas = params[:instalment][:number_inst].to_i
      quota_total = invoices.sum(&:debt) + charge
      single_quota = (quota_total / number_quotas).round(4)
      debugger
      plan = InstalmentPlan.create( instalment_no: "000000000000-000",
                      instalment_date: Date.today,
                      payment_method_id: 1, #CAMBIAR POR ELECCION
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
                    surcharge: (charge / number_quotas).round(2) )
      end
      invoices.each do |i|
        i.invoice_status_id = 5
        i.save
      end
      redirect_to client_payments_path
    end

    def instalment
      instalment = Instalment.find(params[:instalment_id])
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
        redirect_to client_payments_path, notice: "Cobro realizado con exito"
      else
        redirect_to client_payments_path, alert: "Error al realizar el cobro"
      end
    end

    def index
      bill_no = params[:bill_no]
      client = params[:client]
      project = params[:project]
      bank_account = params[:bank_account]
      billing_period = params[:billing_period]
      reading_routes = params[:reading_routes]

      if !current_projects_ids.blank?
        @bills = Bill.where(project_id: current_projects_ids)
        @billing_periods = BillingPeriod.where(project_id: current_projects_ids)
        @reading_routes = ReadingRoute.where(project_id: current_projects_ids)
      elsif session[:office] == "0" || session[:office].nil?
        @bills = Bill.where("subscriber_id != 'nil'")
      else
        @bills = Office.find(session[:office]).subscribers.map(&:bills).flatten
      end
      if session[:organization] != '0'
        @clients = Client.where(organization_id: session[:organization])
      else
        @clients = Client.all
      end
      @projects = current_projects
      @bills_pending = @bills.where("invoice_status_id < 99").order("created_at DESC")
      @bills_charged = @bills.where("invoice_status_id = 99").order("created_at DESC")
      @client_payments_cash = @bills_pending.map(&:invoices).flatten.map(&:client_payments).flatten.select{|c| c.payment_type == ClientPayment::CASH}
      @client_payments_bank = @bills_pending.map(&:invoices).flatten.map(&:client_payments).flatten.select{|c| c.payment_type == ClientPayment::BANK}
      @client_payments_others = @bills.map(&:invoices).flatten.map(&:client_payments).flatten.select{|c| c.payment_type == ClientPayment::OTHERS}
      @instalments = @bills_pending.where(invoice_status_id: InvoiceStatus::FRACTIONATED).map(&:instalments).flatten.map{|i| i  if i.client_payment.nil?}.compact

      # @bills_cash = @bills.where(invoice_status_id: InvoiceStatus::CASH).order("created_at DESC")
      # @bills_bank = @bills.where(invoice_status_id: InvoiceStatus::BANK).order("created_at DESC")
      # @bills_refund = @bills.where(invoice_status_id: InvoiceStatus::REFUND).order("created_at DESC")
      # @bills_charged = @bills.where(invoice_status_id: InvoiceStatus::CHARGED).order("created_at DESC")
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bills }
      end
    end


  end
end
