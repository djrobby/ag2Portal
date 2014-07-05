require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PurchaseOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:po_update_description_prices_from_product,
                                               :po_update_project_from_order,
                                               :po_update_charge_account_from_project,
                                               :po_update_amount_from_price_or_quantity,
                                               :po_update_offer_select_from_supplier,
                                               :po_format_numbers,
                                               :po_totals,
                                               :po_current_stock]
    # Update offer select at view from supplier select
    def po_update_offer_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @offers = @supplier.blank? ? Offer.order(:supplier_id, :offer_no, :id) : @supplier.offers.order(:supplier_id, :offer_no, :id)
      else
        @offers = Offer.order(:supplier_id, :offer_no, :id)
      end

      respond_to do |format|
        format.html # po_update_offer_textfield_from_supplier.html.erb does not exist! JSON only
        format.json { render json: @offers }
      end
    end

    # Update description and prices text fields at view from product select
    def po_update_description_prices_from_product
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
        @product = Product.find(params[:product])
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
      # Setup JSON
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }

      respond_to do |format|
        format.html # po_update_description_prices_from_product.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update project, charge account and store text fields at view from work order select
    def po_update_project_from_order
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

      respond_to do |format|
        format.html # po_update_project_from_order.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update charge account and store text fields at view from project select
    def po_update_charge_account_from_project
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

      respond_to do |format|
        format.html # po_update_charge_account_from_project.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def po_update_amount_from_price_or_quantity
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

      respond_to do |format|
        format.html # po_update_amount_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Format numbers properly
    def po_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Calculate and format totals properly
    def po_totals
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

    # Update current stock text field at view from store select
    def po_current_stock
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
    # GET /purchase_orders
    # GET /purchase_orders.json
    def index
      supplier = params[:Supplier]
      status = params[:Status]

      @search = PurchaseOrder.search do
        fulltext params[:search]
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !status.blank?
          with :order_status_id, status
        end
        order_by :order_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @purchase_orders = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @statuses = OrderStatus.order('id') if @statuses.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @purchase_orders }
      end
    end
  
    # GET /purchase_orders/1
    # GET /purchase_orders/1.json
    def show
      @breadcrumb = 'read'
      @purchase_order = PurchaseOrder.find(params[:id])
      @items = @purchase_order.purchase_order_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @purchase_order }
      end
    end
  
    # GET /purchase_orders/new
    # GET /purchase_orders/new.json
    def new
      @breadcrumb = 'create'
      @purchase_order = PurchaseOrder.new
      @offers = Offer.order(:supplier_id, :offer_no, :id)
      @work_orders = WorkOrder.order(:order_no)
      @projects = Project.order(:project_code)
      @charge_accounts = ChargeAccount.order(:account_code)
      @stores = Store.order(:name)
      #@purchase_order.purchase_order_items.build
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @purchase_order }
      end
    end
  
    # GET /purchase_orders/1/edit
    def edit
      @breadcrumb = 'update'
      @purchase_order = PurchaseOrder.find(params[:id])
      @offers = @purchase_order.supplier.blank? ? Offer.order(:supplier_id, :offer_no, :id) : @purchase_order.supplier.offers.order(:supplier_id, :offer_no, :id)
      @work_orders = @purchase_order.work_order.blank? ? WorkOrder.order(:order_no) : WorkOrder.where('id = ?', @purchase_order.work_order)
      @projects = @purchase_order.project.blank? ? Project.order(:project_code) : Project.where('id = ?', @purchase_order.project)
      @charge_accounts = @purchase_order.charge_account.blank? ? ChargeAccount.order(:account_code) : ChargeAccount.where('id = ?', @purchase_order.charge_account)
      @stores = @purchase_order.store.blank? ? Store.order(:name) : Store.where('id = ?', @purchase_order.store)
      #@items = @purchase_order.purchase_order_items.order('id')
    end
  
    # POST /purchase_orders
    # POST /purchase_orders.json
    def create
      @breadcrumb = 'create'
      @purchase_order = PurchaseOrder.new(params[:purchase_order])
      @purchase_order.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @purchase_order.save
          format.html { redirect_to @purchase_order, notice: crud_notice('created', @purchase_order) }
          format.json { render json: @purchase_order, status: :created, location: @purchase_order }
        else
          @offers = Offer.order(:supplier_id, :offer_no, :id)
          @work_orders = WorkOrder.order(:order_no)
          @projects = Project.order(:project_code)
          @charge_accounts = ChargeAccount.order(:account_code)
          @stores = Store.order(:name)
          format.html { render action: "new" }
          format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /purchase_orders/1
    # PUT /purchase_orders/1.json
    def update
      @breadcrumb = 'update'
      @purchase_order = PurchaseOrder.find(params[:id])
      @purchase_order.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @purchase_order.update_attributes(params[:purchase_order])
          format.html { redirect_to @purchase_order,
                        notice: (crud_notice('updated', @purchase_order) + "#{undo_link(@purchase_order)}").html_safe }
          format.json { head :no_content }
        else
          @offers = @purchase_order.supplier.blank? ? Offer.order(:supplier_id, :offer_no, :id) : @purchase_order.supplier.offers.order(:supplier_id, :offer_no, :id)
          @work_orders = @purchase_order.work_order.blank? ? WorkOrder.order(:order_no) : WorkOrder.where('id = ?', @purchase_order.work_order)
          @projects = @purchase_order.project.blank? ? Project.order(:project_code) : Project.where('id = ?', @purchase_order.project)
          @charge_accounts = @purchase_order.charge_account.blank? ? ChargeAccount.order(:account_code) : ChargeAccount.where('id = ?', @purchase_order.charge_account)
          @stores = @purchase_order.store.blank? ? Store.order(:name) : Store.where('id = ?', @purchase_order.store)
          format.html { render action: "edit" }
          format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /purchase_orders/1
    # DELETE /purchase_orders/1.json
    def destroy
      @purchase_order = PurchaseOrder.find(params[:id])

      respond_to do |format|
        if @purchase_order.destroy
          format.html { redirect_to purchase_orders_url,
                      notice: (crud_notice('destroyed', @purchase_order) + "#{undo_link(@purchase_order)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to purchase_orders_url, alert: "#{@purchase_order.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
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
  end
end
