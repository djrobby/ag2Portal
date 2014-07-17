require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierPaymentsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /supplier_payments
    # GET /supplier_payments.json
    def index
      manage_filter_state
      supplier = params[:Supplier]
      invoice = params[:Invoice]

      @search = SupplierPayment.search do
        fulltext params[:search]
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !invoice.blank?
          with :supplier_invoice_id, invoice
        end
        order_by :payment_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @supplier_payments = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @invoices = SupplierInvoice.order('id') if @invoices.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_payments }
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
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_payment }
      end
    end
  
    # GET /supplier_payments/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_payment = SupplierPayment.find(params[:id])
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
    
    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
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
