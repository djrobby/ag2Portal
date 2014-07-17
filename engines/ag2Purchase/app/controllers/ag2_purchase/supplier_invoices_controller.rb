require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierInvoicesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    def index
      manage_filter_state
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]

      @search = SupplierInvoice.search do
        fulltext params[:search]
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @supplier_invoices = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @projects = Project.order('project_code') if @projects.nil?
      @work_orders = WorkOrder.order('order_no') if @work_orders.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_invoices }
      end
    end
  
    # GET /supplier_invoices/1
    # GET /supplier_invoices/1.json
    def show
      @breadcrumb = 'read'
      @supplier_invoice = SupplierInvoice.find(params[:id])
      @items = @supplier_invoice.supplier_invoice_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @approvals = @supplier_invoice.supplier_invoice_approvals.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/new
    # GET /supplier_invoices/new.json
    def new
      @breadcrumb = 'create'
      @supplier_invoice = SupplierInvoice.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_invoice = SupplierInvoice.find(params[:id])
    end
  
    # POST /supplier_invoices
    # POST /supplier_invoices.json
    def create
      @breadcrumb = 'create'
      @supplier_invoice = SupplierInvoice.new(params[:supplier_invoice])
      @supplier_invoice.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @supplier_invoice.save
          format.html { redirect_to @supplier_invoice, notice: crud_notice('created', @supplier_invoice) }
          format.json { render json: @supplier_invoice, status: :created, location: @supplier_invoice }
        else
          format.html { render action: "new" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /supplier_invoices/1
    # PUT /supplier_invoices/1.json
    def update
      @breadcrumb = 'update'
      @supplier_invoice = SupplierInvoice.find(params[:id])
      @supplier_invoice.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @supplier_invoice.update_attributes(params[:supplier_invoice])
          format.html { redirect_to @supplier_invoice,
                        notice: (crud_notice('updated', @supplier_invoice) + "#{undo_link(@supplier_invoice)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /supplier_invoices/1
    # DELETE /supplier_invoices/1.json
    def destroy
      @supplier_invoice = SupplierInvoice.find(params[:id])

      respond_to do |format|
        if @supplier_invoice.destroy
          format.html { redirect_to supplier_invoices_url,
                      notice: (crud_notice('destroyed', @supplier_invoice) + "#{undo_link(@supplier_invoice)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to supplier_invoices_url, alert: "#{@supplier_invoice.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
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
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # order
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
    end
  end
end
