require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PurchaseOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:po_update_description_prices_from_product,
                                               :po_update_amount_from_price_or_quantity]
    # Update description and prices text fields at view from product select
    def po_update_description_prices_from_product
      @product = Product.find(params[:product])
      @prices = @product.purchase_prices
      qty = params[:qty].to_f / 10000
      price = @product.reference_price
      amount = qty * price
      tax = amount * (@product.tax_type.tax / 100)
      price = number_with_precision(price, precision: 4)
      tax = number_with_precision(tax, precision: 4)
      amount = number_with_precision(amount, precision: 4)
      @json_data = { "description" => @product.main_description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => @product.tax_type.id }

      respond_to do |format|
        format.html # po_update_description_prices_from_product.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update project and charge account text fields at view from work order select
    def po_update_project_from_order
      order = params[:order]
      if order != '0'
        @order = WorkOrder.find(order)
        @project = @order.project
        @charge_account = @order.charge_account
        if @charge_account.blank?
          @charge_account = @project.blank? ? ChargeAccount.all(order: 'account_code') : @project.charge_accounts(order: 'account_code')
        end
        if !@project.company.blank? && !@project.office.blank?
          @store = Store.where("company_id = ? AND office_id = ?", @project.company_id, @project.office_id).order('name')
        elsif !@project.company.blank? && @project.office.blank?
          @store = Store.where("company_id = ?", @project.company_id).order('name')
        elsif @project.company.blank? && !@project.office.blank?
          @store = Store.where("office_id = ?", @project.office_id).order('name')
        else
          @store = Store.all(order: 'name')
        end
      else
        @project = Project.all(order: 'name')
        @charge_account = ChargeAccount.all(order: 'account_code')
        @store = Store.all(order: 'name')
      end
      @json_data = { "project" => @project, "charge_account" => @charge_account, "store" => @store }

      respond_to do |format|
        format.html # po_update_project_from_order.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update charge account text fields at view from project select
    def po_update_charge_account_from_project
      project = params[:order]
      if project != '0'
        @project = Project.find(project)
        @charge_accounts = @project.blank? ? ChargeAccount.all(order: 'account_code') : @project.charge_accounts(order: 'account_code')
      else
        @charge_accounts = ChargeAccount.all(order: 'account_code')
      end

      respond_to do |format|
        format.html # po_update_charge_account_from_project.html.erb does not exist! JSON only
        format.json { render json: @charge_accounts }
      end
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def po_update_amount_from_price_or_quantity
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      discount_p = params[:discount_p].to_f / 100
      discount = params[:discount].to_f / 10000
      if tax_type.blank? || tax_type == "0"
        tax_type = Product.find(params[:product]).tax_type.id
      end
      tax = TaxType.find(tax_type).tax
      if discount_p > 0
        discount = price * (discount_p / 100)
      end
      amount = qty * (price - discount)
      tax = amount * (tax / 100)
      qty = number_with_precision(qty, precision: 4)
      price = number_with_precision(price, precision: 4)
      amount = number_with_precision(amount, precision: 4)
      tax = number_with_precision(tax, precision: 4)
      discount_p = number_with_precision(discount_p, precision: 2)
      discount = number_with_precision(discount, precision: 4)
      @json_data = { "quantity" => qty.to_s, "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discountp" => discount_p.to_s, "discount" => discount.to_s }

      respond_to do |format|
        format.html # po_update_amount_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /purchase_orders
    # GET /purchase_orders.json
    def index
      @purchase_orders = PurchaseOrder.paginate(:page => params[:page], :per_page => per_page).order('order_no')
  
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
      @items = @purchase_order.purchase_order_items.order('id')
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
  end
end
