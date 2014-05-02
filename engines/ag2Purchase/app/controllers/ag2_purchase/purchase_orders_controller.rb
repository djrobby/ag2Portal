require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PurchaseOrdersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:po_update_description_prices_from_product]

    # Update description and prices text fields at view from product select
    def po_update_description_prices_from_product
      @product = Product.find(params[:product])
      @prices = @product.purchase_prices
      price = @product.reference_price
      tax = (params[:qty].to_f * price) * @product.tax_type.tax
      @json_data = { "description" => @product.main_description, "price" => price.to_s, "tax" => tax.to_s }

      respond_to do |format|
        format.html # po_update_description_prices_from_product.html.erb does not exist! JSON only
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
