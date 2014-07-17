require_dependency "ag2_products/application_controller"

module Ag2Products
  class ReceiptNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:rn_totals,
                                               :rn_update_description_prices_from_product,
                                               :rn_update_amount_from_price_or_quantity,
                                               :rn_update_project_from_order,
                                               :rn_update_charge_account_from_project,
                                               :rn_update_order_select_from_supplier,
                                               :rn_format_number,
                                               :rn_current_stock]
    # Calculate and format totals properly
    def rn_totals
      qty = params[:qty].to_f / 10000
      amount = params[:amount].to_f / 10000
      tax = params[:tax].to_f / 10000
      discount_p = params[:discount_p].to_f / 100
      # Bonus
      discount = discount_p != 0 ? amount * (discount_p / 100) : 0
      # Taxable
      taxable = amount - discount
      # Taxes
      tax = tax - (tax * (discount_p / 100)) if discount_p != 0
      # Total
      total = taxable + tax      
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount = number_with_precision(discount.round(4), precision: 4)
      taxable = number_with_precision(taxable.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discount" => discount.to_s, "taxable" => taxable.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def rn_update_description_prices_from_product
      product = params[:product]
      store = params[:store]
      description = ""
      qty = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      current_stock = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        price = @product.reference_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def rn_update_amount_from_price_or_quantity
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      discount_p = params[:discount_p].to_f / 100
      discount = params[:discount].to_f / 10000
      product = params[:product]
      if tax_type.blank? || tax_type == "0"
        if !product.blank? && product != "0"
          tax_type = Product.find(product).tax_type.id
        else
          tax_type = TaxType.where('expiration IS NULL').order('id').first.id
        end
      end
      tax = TaxType.find(tax_type).tax
      if discount_p > 0
        discount = price * (discount_p / 100)
      end
      amount = qty * (price - discount)
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s, "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discountp" => discount_p.to_s, "discount" => discount.to_s }
      render json: @json_data
    end

    # Update project, charge account and store text fields at view from work order select
    def rn_update_project_from_order
      order = params[:order]
      project_id = 0
      charge_account_id = 0
      store_id = 0
      if order != '0'
        @order = WorkOrder.find(order)
        @project = @order.project
        project_id = @project.id rescue 0
        @charge_account = @order.charge_account
        charge_account_id = @charge_account.id rescue 0
        @store = @order.store
        store_id = @store.id rescue 0
        if @charge_account.blank?
          @charge_account = @project.blank? ? ChargeAccount.all(order: 'account_code') : @project.charge_accounts(order: 'account_code')
        end
        if @store.blank?
          @store = project_stores(@project)
        end
      else
        @project = Project.all(order: 'name')
        @charge_account = ChargeAccount.all(order: 'account_code')
        @store = Store.all(order: 'name')
      end
      @json_data = { "project" => @project, "charge_account" => @charge_account, "store" => @store,
                     "project_id" => project_id, "charge_account_id" => charge_account_id, "store_id" => store_id }
      render json: @json_data
    end

    # Update charge account and store text fields at view from project select
    def rn_update_charge_account_from_project
      project = params[:order]
      if project != '0'
        @project = Project.find(project)
        @charge_account = @project.blank? ? ChargeAccount.all(order: 'account_code') : @project.charge_accounts(order: 'account_code')
        @store = project_stores(@project)
      else
        @charge_account = ChargeAccount.all(order: 'account_code')
        @store = Store.all(order: 'name')
      end
      @json_data = { "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Update purchase order select at view from supplier select
    def rn_update_order_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @orders = @supplier.blank? ? PurchaseOrder.order(:supplier_id, :order_no, :id) : @supplier.purchase_orders.order(:supplier_id, :order_no, :id)
      else
        @orders = PurchaseOrder.order(:supplier_id, :order_no, :id)
      end

      respond_to do |format|
        format.html # rn_update_order_select_from_supplier.html.erb does not exist! JSON only
        format.json { render json: @orders }
      end
    end

    # Format numbers properly
    def rn_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def rn_current_stock
      product = params[:product]
      store = params[:store]
      current_stock = 0
      if product != '0' && store != '0'
        current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
      end
      # Format numbers
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON
      @json_data = { "stock" => current_stock.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    # GET /receipt_notes
    # GET /receipt_notes.json
    def index
      manage_filter_state
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]

      @search = ReceiptNote.search do
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
      @receipt_notes = @search.results

      # Initialize select_tags
      @suppliers_s = Supplier.order('name') if @suppliers_s.nil?
      @projects_s = Project.order('project_code') if @projects_s.nil?
      @work_orders_s = WorkOrder.order('order_no') if @work_orders_s.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @receipt_notes }
      end
    end
  
    # GET /receipt_notes/1
    # GET /receipt_notes/1.json
    def show
      @breadcrumb = 'read'
      @receipt_note = ReceiptNote.find(params[:id])
      @items = @receipt_note.receipt_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/new
    # GET /receipt_notes/new.json
    def new
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new
      @orders = PurchaseOrder.order(:supplier_id, :order_no, :id)
      @work_orders = WorkOrder.order(:order_no)
      @projects = Project.order(:project_code)
      @charge_accounts = ChargeAccount.order(:account_code)
      @stores = Store.order(:name)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
      @orders = @receipt_note.supplier.blank? ? PurchaseOrder.order(:supplier_id, :order_no, :id) : @receipt_note.supplier.purchase_orders.order(:supplier_id, :order_no, :id)
      @work_orders = @purchase_order.work_order.blank? ? WorkOrder.order(:order_no) : WorkOrder.where('id = ?', @purchase_order.work_order)
      @projects = @purchase_order.project.blank? ? Project.order(:project_code) : Project.where('id = ?', @purchase_order.project)
      @charge_accounts = @purchase_order.charge_account.blank? ? ChargeAccount.order(:account_code) : ChargeAccount.where('id = ?', @purchase_order.charge_account)
      @stores = @purchase_order.store.blank? ? Store.order(:name) : Store.where('id = ?', @purchase_order.store)
    end
  
    # POST /receipt_notes
    # POST /receipt_notes.json
    def create
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new(params[:receipt_note])
      @receipt_note.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @receipt_note.save
          format.html { redirect_to @receipt_note, notice: crud_notice('created', @receipt_note) }
          format.json { render json: @receipt_note, status: :created, location: @receipt_note }
        else
          @orders = PurchaseOrder.order(:supplier_id, :order_no, :id)
          @work_orders = WorkOrder.order(:order_no)
          @projects = Project.order(:project_code)
          @charge_accounts = ChargeAccount.order(:account_code)
          @stores = Store.order(:name)
          format.html { render action: "new" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /receipt_notes/1
    # PUT /receipt_notes/1.json
    def update
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
      @receipt_note.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @receipt_note.update_attributes(params[:receipt_note])
          format.html { redirect_to @receipt_note,
                        notice: (crud_notice('updated', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
          format.json { head :no_content }
        else
          @orders = @receipt_note.supplier.blank? ? PurchaseOrder.order(:supplier_id, :order_no, :id) : @receipt_note.supplier.purchase_orders.order(:supplier_id, :order_no, :id)
          @work_orders = @purchase_order.work_order.blank? ? WorkOrder.order(:order_no) : WorkOrder.where('id = ?', @purchase_order.work_order)
          @projects = @purchase_order.project.blank? ? Project.order(:project_code) : Project.where('id = ?', @purchase_order.project)
          @charge_accounts = @purchase_order.charge_account.blank? ? ChargeAccount.order(:account_code) : ChargeAccount.where('id = ?', @purchase_order.charge_account)
          @stores = @purchase_order.store.blank? ? Store.order(:name) : Store.where('id = ?', @purchase_order.store)
          format.html { render action: "edit" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /receipt_notes/1
    # DELETE /receipt_notes/1.json
    def destroy
      @receipt_note = ReceiptNote.find(params[:id])

      respond_to do |format|
        if @receipt_note.destroy
          format.html { redirect_to receipt_notes_url,
                      notice: (crud_notice('destroyed', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to receipt_notes_url, alert: "#{@receipt_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
    
    private
    
    def project_stores(_project)
      if !_project.company.blank? && !_project.office.blank?
        _store = Store.where("company_id = ? AND office_id = ?", _project.company.id, _project.office.id)
      elsif !_project.company.blank? && _project.office.blank?
        _store = Store.where("company_id = ?", _project.company.id)
      elsif _project.company.blank? && !_project.office.blank?
        _store = Store.where("office_id = ?", _project.office.id)
      else
        _store = Store.all(order: 'name')
      end
      _store
    end
    
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
