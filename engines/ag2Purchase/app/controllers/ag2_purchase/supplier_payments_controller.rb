require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierPaymentsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:sp_generate_no,
                                               :sp_update_from_organization,
                                               :sp_update_from_supplier,
                                               :sp_update_from_invoice,
                                               :sp_update_from_approval,
                                               :sp_format_number]
    # Update payment number at view (generate_code_btn)
    def sp_generate_no
      organization = params[:org]

      # Builds no, if possible
      code = organization == '$' ? '$err' : sp_next_no(organization)
      @json_data = { "code" => code }
      render json: @json_data
    end

    def sp_update_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        invoices = @organization.blank? ? invoices_dropdown : @organization.supplier_invoice_debts.order(:supplier_invoice_id)
        #@supplier_invoices = @organization.blank? ? invoices_array(invoices_dropdown) : invoices_array(@organization.supplier_invoice_debts.order(:supplier_invoice_id))
        #@approvals = approvals_dropdown(@supplier_invoices)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : payment_payment_methods(@organization.id)
      else
        @suppliers = suppliers_dropdown
        invoices = invoices_dropdown
        @payment_methods = payment_methods_dropdown
      end
      @supplier_invoices = invoices_array(invoices)
      @approvals = approvals_dropdown(invoices)
      # Setup JSON
      @json_data = { "supplier" => @suppliers, "invoice" => @supplier_invoices,
                     "approval" => @approvals, "payment_method" => @payment_methods }
      render json: @json_data
    end

    def sp_update_from_supplier
      supplier = params[:supplier]
      payment_method_id = 0
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        invoices = @supplier.blank? ? invoices_dropdown : @supplier.supplier_invoice_debts.order(:supplier_invoice_id)
        #@supplier_invoices = @supplier.blank? ? invoices_array(invoices_dropdown) : invoices_array(@supplier.supplier_invoice_debts.order(:supplier_invoice_id))
        #@approvals = approvals_dropdown(@supplier_invoices)
        @payment_methods = @supplier.blank? ? payment_methods_dropdown : @supplier.payment_method
        payment_method_id = @payment_methods.id rescue 0
      else
        invoices = invoices_dropdown
        @payment_methods = payment_methods_dropdown
      end
      @supplier_invoices = invoices_array(invoices)
      @approvals = approvals_dropdown(invoices)
      # Setup JSON
      @json_data = { "invoice" => @supplier_invoices, "approval" => @approvals,
                     "payment_method" => @payment_methods, "payment_method_id" => payment_method_id }
      render json: @json_data
    end

    def sp_update_from_invoice
      invoice = params[:o]
      payment_method_id = 0
      if invoice != '0'
        @supplier_invoice = SupplierInvoiceDebt.where(supplier_invoice_id: invoice)
        @approvals = approvals_dropdown(@supplier_invoice)
        @payment_methods = @supplier_invoice.blank? ? payment_methods_dropdown : @supplier_invoice.first.supplier_invoice.payment_method
        payment_method_id = @payment_methods.id rescue 0
      else
        @approvals = approvals_dropdown(invoices_dropdown)
        @payment_methods = payment_methods_dropdown
      end
      # Setup JSON
      @json_data = { "approval" => @approvals,
                     "payment_method" => @payment_methods, "payment_method_id" => payment_method_id }
      render json: @json_data
    end

    def sp_update_from_approval
      approval = params[:o]
      approver = 0
      amount = 0
      if approval != '0'
        @approval = SupplierInvoiceApproval.find(approval)
        approver = @approval.approver_id rescue 0
        amount = @approval.approved_amount rescue 0
      end
      amount = number_with_precision(amount.round(4), precision: 4)
      # Setup JSON
      @json_data = { "approver" => approver, "amount" => amount.to_s }
      render json: @json_data
    end

    # Format numbers properly
    def sp_format_number
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /supplier_payments
    # GET /supplier_payments.json
    def index
      manage_filter_state
      no = params[:No]
      supplier = params[:Supplier]
      invoice = params[:Invoice]

      # Arrays for search
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = SupplierPayment.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :payment_no, no
          else
            with(:payment_no).starting_with(no)
          end
        end
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !invoice.blank?
          with :supplier_invoice_id, invoice
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @supplier_payments = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @invoices = SupplierInvoice.order('id') if @invoices.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_payments }
        format.js
      end
    end
  
    # GET /supplier_payments/1
    # GET /supplier_payments/1.json
    def show
      @breadcrumb = 'read'
      @supplier_payment = SupplierPayment.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_payment }
      end
    end
  
    # GET /supplier_payments/new
    # GET /supplier_payments/new.json
    def new
      @breadcrumb = 'create'
      @supplier_payment = SupplierPayment.new
      @suppliers = suppliers_dropdown
      invoices = invoices_dropdown
      @supplier_invoices = invoices
      @approvals = approvals_dropdown_on_model(invoices)
      #@approvals = approvals_dropdown(invoices)
      @users = User.all
      @payment_methods = payment_methods_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_payment }
      end
    end
  
    # GET /supplier_payments/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_payment = SupplierPayment.find(params[:id])
      @suppliers = suppliers_dropdown
      invoices = invoices_dropdown
      @supplier_invoices = invoices
      @approvals = approvals_dropdown_on_model(invoices)
      @users = User.all
      @payment_methods = payment_methods_dropdown
    end
  
    # POST /supplier_payments
    # POST /supplier_payments.json
    def create
      @breadcrumb = 'create'
      @supplier_payment = SupplierPayment.new(params[:supplier_payment])
      @supplier_payment.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @supplier_payment.save
          format.html { redirect_to @supplier_payment, notice: crud_notice('created', @supplier_payment) }
          format.json { render json: @supplier_payment, status: :created, location: @supplier_payment }
        else
          @suppliers = suppliers_dropdown
          invoices = invoices_dropdown
          @supplier_invoices = invoices
          @approvals = approvals_dropdown_on_model(invoices)
          @users = User.all
          @payment_methods = payment_methods_dropdown
          format.html { render action: "new" }
          format.json { render json: @supplier_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /supplier_payments/1
    # PUT /supplier_payments/1.json
    def update
      @breadcrumb = 'update'
      @supplier_payment = SupplierPayment.find(params[:id])
      @supplier_payment.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @supplier_payment.update_attributes(params[:supplier_payment])
          format.html { redirect_to @supplier_payment,
                        notice: (crud_notice('updated', @supplier_payment) + "#{undo_link(@supplier_payment)}").html_safe }
          format.json { head :no_content }
        else
          @suppliers = suppliers_dropdown
          invoices = invoices_dropdown
          @supplier_invoices = invoices
          @approvals = approvals_dropdown_on_model(invoices)
          @users = User.all
          @payment_methods = payment_methods_dropdown
          format.html { render action: "edit" }
          format.json { render json: @supplier_payment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /supplier_payments/1
    # DELETE /supplier_payments/1.json
    def destroy
      @supplier_payment = SupplierPayment.find(params[:id])

      respond_to do |format|
        if @supplier_payment.destroy
          format.html { redirect_to supplier_payments_url,
                      notice: (crud_notice('destroyed', @supplier_payment) + "#{undo_link(@supplier_payment)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to supplier_payments_url, alert: "#{@supplier_payment.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @supplier_payment.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      SupplierPayment.where('payment_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.payment_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def suppliers_dropdown
      session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def invoices_dropdown
      session[:organization] != '0' ? SupplierInvoiceDebt.where(organization_id: session[:organization].to_i).order(:supplier_invoice_id) : SupplierInvoiceDebt.order(:supplier_invoice_id)
    end
    
    def invoices_array(_invoices) # based on SupplierInvoiceDebt
      _array = []
      _invoices.each do |i|
        _array = _array << [ i.supplier_invoice_id, i.invoice_no,
                             formatted_date(i.supplier_invoice.invoice_date),
                             i.supplier_invoice.supplier.full_name,
                             (!i.total.blank? ? formatted_number(i.total, 2) : formatted_number(0, 2)),
                             (!i.paid.blank? ? formatted_number(i.paid, 2) : formatted_number(0, 2)),
                             (!i.debt.blank? ? formatted_number(i.debt, 2) : formatted_number(0, 2)) ]
      end
      _array
    end

    def approvals_dropdown_on_model(_invoices)  # returns array of model
      _array = []
      _invoices.each do |i|           # i = SupplierInvoiceDebt
        approvals = i.supplier_invoice.supplier_invoice_approvals
        if approvals.count > 0
          approvals.each do |a|       # a = SupplierInvoiceApproval
            if a.debt > 0
              _array = _array << a
            end
          end
        end
      end
      _array
    end

    def approvals_dropdown(_invoices) # returns array
      _array = []
      _invoices.each do |i|           # i = SupplierInvoiceDebt
        approvals = i.supplier_invoice.supplier_invoice_approvals
        if approvals.count > 0
          approvals.each do |a|       # a = SupplierInvoiceApproval
            if a.debt > 0
              _array = _array << [ a.id, i.supplier_invoice.invoice_no, 
                                   a.approver.email, formatted_date(a.approval_date),
                                  (!a.debt.blank? ? formatted_number(a.debt, 4) : formatted_number(0, 4)) ]
            end 
          end
        end
      end
      _array
    end

    def payment_methods_dropdown
      session[:organization] != '0' ? payment_payment_methods(session[:organization].to_i) : payment_payment_methods(0)
    end
    
    def payment_payment_methods(_organization)
      if _organization != 0
        _methods = PaymentMethod.where("(flow = 3 OR flow = 2) AND organization_id = ?", _organization).order(:description)
      else
        _methods = PaymentMethod.where("flow = 3 OR flow = 2").order(:description)
      end
      _methods
    end
    
    # Keeps filter state
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
      # supplier
      if params[:Supplier]
        session[:Supplier] = params[:Supplier]
      elsif session[:Supplier]
        params[:Supplier] = session[:Supplier]
      end
      # invoice
      if params[:Invoice]
        session[:Invoice] = params[:Invoice]
      elsif session[:Invoice]
        params[:Invoice] = session[:Invoice]
      end
    end
  end
end
