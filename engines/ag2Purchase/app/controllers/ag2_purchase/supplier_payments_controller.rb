require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierPaymentsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:sp_generate_no,
                                               :sp_update_from_organization,
                                               :sp_update_from_supplier,
                                               :sp_update_from_invoice]

    # Update delivery number at view (generate_code_btn)
    def sp_generate_no
      organization = params[:org]

      # Builds no, if possible
      code = organization == '$' ? '$err' : sp_next_no(organization)
      @json_data = { "code" => code }
      render json: @json_data
    end

    def sp_update_from_organization
      
    end

    def sp_update_from_supplier
      
    end

    def sp_update_from_invoice
      
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
      @supplier_invoices = invoices_array(invoices_dropdown)
      @approvals = approvals_dropdown
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
      @supplier_invoices = invoices_array(invoices_dropdown)
      @approvals = approvals_dropdown
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
          @supplier_invoices = invoices_array(invoices_dropdown)
          @approvals = approvals_dropdown
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
          @supplier_invoices = invoices_array(invoices_dropdown)
          @approvals = approvals_dropdown
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
                             (!i.total.blank? ? formatted_number(i.total, 4) : formatted_number(0, 4)),
                             (!i.paid.blank? ? formatted_number(i.paid, 4) : formatted_number(0, 4)),
                             (!i.debt.blank? ? formatted_number(i.debt, 4) : formatted_number(0, 4)) ]
      end
      _array
    end

    def approvals_dropdown  # returns array
      _array = []
      invoices = invoices_dropdown
      invoices.each do |i|
        approvals = i.supplier_invoice.supplier_invoice_approvals
        if approvals.count > 0
          approvals.each do |a|
            _array = _array << [ i.id, i.supplier_invoice.invoice_no, 
                                 i.approver.email, formatted_timestamp(i.approval_date),
                                (!i.approved_amount.blank? ? formatted_number(i.approved_amount, 4) : formatted_number(0, 4)) ]
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
