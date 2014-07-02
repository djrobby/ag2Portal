require_dependency "ag2_products/application_controller"

module Ag2Products
  class DeliveryNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:dn_totals,
                                               :dn_update_description_prices_from_product,
                                               :dn_update_amount_and_costs_from_price_or_quantity,
                                               :dn_update_project_from_order,
                                               :dn_update_charge_account_from_project,
                                               :dn_update_offer_select_from_client,
                                               :dn_format_number]
                                               
    # Calculate and format totals properly
    def dn_totals
      qty = params[:qty].to_f / 10000
      amount = params[:amount].to_f / 10000
      costs = params[:costs].to_f / 10000
      tax = params[:tax].to_f / 10000
      discount_p = params[:discount_p].to_f / 100
      # Bonus
      discount = discount_p != 0 ? amount * (discount_p / 100) : 0
      # Taxable
      taxable = amount
      # Total
      total = taxable + tax      
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount = number_with_precision(discount.round(4), precision: 4)
      taxable = number_with_precision(taxable.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "costs" => costs.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discount" => discount.to_s, "taxable" => taxable.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def dn_update_description_prices_from_product
      product = params[:product]
      description = ""
      qty = 0
      cost = 0
      costs = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        cost = @product.reference_price
        costs = qty * cost
        price = @product.sell_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "description" => description,
                     "cost" => cost.to_s, "costs" => costs.to_s,
                     "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id }
      render json: @json_data
    end

    # Update amount, costs and tax text fields at view (quantity or price changed)
    def dn_update_amount_and_costs_from_price_or_quantity
      cost = params[:cost].to_f / 10000
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
      costs = qty * cost
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s, "cost" => cost.to_s, "costs" => costs.to_s, 
                     "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discountp" => discount_p.to_s, "discount" => discount.to_s }
      render json: @json_data
    end

    # Update project, charge account and store text fields at view from work order select
    def dn_update_project_from_order
      order = params[:order]
      if order != '0'
        @order = WorkOrder.find(order)
        @project = @order.project
        @charge_account = @order.charge_account
        @store = @order.store
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
      @json_data = { "project" => @project, "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Update charge account and store text fields at view from project select
    def dn_update_charge_account_from_project
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

    # Update sale offer select at view from client select
    def dn_update_offer_select_from_client
      client = params[:client]
      if client != '0'
        @client = Client.find(client)
        @offers = @client.blank? ? SaleOffer.order(:client_id, :offer_no, :id) : @client.sale_offers.order(:client_id, :offer_no, :id)
      else
        @offers = SaleOffer.order(:client_id, :offer_no, :id)
      end

      respond_to do |format|
        format.html # dn_update_offer_select_from_client.html.erb does not exist! JSON only
        format.json { render json: @offers }
      end
    end

    # Format numbers properly
    def po_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    # GET /delivery_notes
    # GET /delivery_notes.json
    def index
      client = params[:Client]
      project = params[:Project]
      order = params[:Order]

      @search = DeliveryNote.search do
        fulltext params[:search]
        if !client.blank?
          with :client_id, client
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :delivery_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @delivery_notes = @search.results

      # Initialize select_tags
      @clients = Client.order('name') if @clients.nil?
      @projects = Project.order('project_code') if @projects.nil?
      @work_orders = WorkOrder.order('order_no') if @work_orders.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @delivery_notes }
      end
    end
  
    # GET /delivery_notes/1
    # GET /delivery_notes/1.json
    def show
      @breadcrumb = 'read'
      @delivery_note = DeliveryNote.find(params[:id])
      @items = @delivery_note.delivery_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/new
    # GET /delivery_notes/new.json
    def new
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new
      @offers = SaleOffer.order(:client_id, :offer_no, :id)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
      @offers = @delivery_note.client.blank? ? SaleOffer.order(:client_id, :offer_no, :id) : @delivery_note.client.sale_offers.order(:client_id, :offer_no, :id)
    end
  
    # POST /delivery_notes
    # POST /delivery_notes.json
    def create
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new(params[:delivery_note])
      @delivery_note.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.save
          format.html { redirect_to @delivery_note, notice: crud_notice('created', @delivery_note) }
          format.json { render json: @delivery_note, status: :created, location: @delivery_note }
        else
          @offers = SaleOffer.order(:client_id, :offer_no, :id)
          format.html { render action: "new" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /delivery_notes/1
    # PUT /delivery_notes/1.json
    def update
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
      @delivery_note.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.update_attributes(params[:delivery_note])
          format.html { redirect_to @delivery_note,
                        notice: (crud_notice('updated', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          @offers = @delivery_note.client.blank? ? SaleOffer.order(:client_id, :offer_no, :id) : @delivery_note.client.sale_offers.order(:client_id, :offer_no, :id)
          format.html { render action: "edit" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /delivery_notes/1
    # DELETE /delivery_notes/1.json
    def destroy
      @delivery_note = DeliveryNote.find(params[:id])

      respond_to do |format|
        if @delivery_note.destroy
          format.html { redirect_to delivery_notes_url,
                      notice: (crud_notice('destroyed', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to delivery_notes_url, alert: "#{@delivery_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
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
