require_dependency "ag2_products/application_controller"

module Ag2Products
  class StocksController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:st_format_numbers]
    $product = nil
    $store = nil

    # Format numbers properly
    def st_format_numbers
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # GET /stocks
    # GET /stocks.json
    def index
      current_product_store
      manage_filter_state
      @product = $product
      @store = $store
      product = nil
      store = nil
      if !$product.nil?
        product = $product.id
      else
        product = params[:Products]
      end
      if !$store.nil?
        store = $store.id
      else
        store = params[:Stores]
      end

      @search = Stock.search do
        #fulltext params[:search]
        if !product.blank?
          with :product_id, product
        end
        if !store.blank?
          with :store_id, store
        end
        order_by :product_id, :asc
        order_by :store_id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @stocks = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @stocks }
        format.js
      end
    end

    # GET /stocks/1
    # GET /stocks/1.json
    def show
      @breadcrumb = 'read'
      @product = $product
      @store = $store
      @stock = Stock.find(params[:id])
      # Receipts & Deliveries
      @receipts = ReceiptNoteItem.joins(:receipt_note).where(product_id: @stock.product, store_id: @stock.store).order('receipt_date desc').paginate(:page => params[:page], :per_page => per_page)
      @deliveries = DeliveryNoteItem.joins(:delivery_note).where(product_id: @stock.product, store_id: @stock.store).order('delivery_date desc').paginate(:page => params[:page], :per_page => per_page)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @stock }
      end
    end

    # GET /stocks/new
    # GET /stocks/new.json
    def new
      @breadcrumb = 'create'
      @product = $product
      @store = $store
      @stock = Stock.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @stock }
      end
    end

    # GET /stocks/1/edit
    def edit
      @breadcrumb = 'update'
      @product = $product
      @store = $store
      @stock = Stock.find(params[:id])
    end

    # POST /stocks
    # POST /stocks.json
    def create
      @breadcrumb = 'update'
      @product = $product
      @store = $store
      @stock = Stock.new(params[:stock])
      @stock.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @stock.save
          format.html { redirect_to @stock, notice: crud_notice('created', @stock) }
          format.json { render json: @stock, status: :created, location: @stock }
        else
          format.html { render action: "new" }
          format.json { render json: @stock.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /stocks/1
    # PUT /stocks/1.json
    def update
      @product = $product
      @store = $store
      @stock = Stock.find(params[:id])
      @stock.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @stock.update_attributes(params[:stock])
          format.html { redirect_to @stock,
                        notice: (crud_notice('updated', @stock) + "#{undo_link(@stock)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @stock.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /stocks/1
    # DELETE /stocks/1.json
    def destroy
      @product = $product
      @store = $store
      @stock = Stock.find(params[:id])
      @stock.destroy

      respond_to do |format|
        if @stock.destroy
          format.html { redirect_to stocks_url,
                      notice: (crud_notice('destroyed', @stock) + "#{undo_link(@stock)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to stocks_url, alert: "#{@stock.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @stock.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /receipts_deliveries
    # GET /receipts_deliveries.json
    def receipts_deliveries
      @stock = Stock.find(params[:id])
      # OCO
      init_oco if !session[:organization]
      # Receipts & Deliveries
      @receipts = ReceiptNoteItem.joins(:receipt_note).where(product_id: @stock.product, store_id: @stock.store).order('receipt_date desc').paginate(:page => params[:page], :per_page => per_page)
      @deliveries = DeliveryNoteItem.joins(:delivery_note).where(product_id: @stock.product, store_id: @stock.store).order('delivery_date desc').paginate(:page => params[:page], :per_page => per_page)

      respond_to do |format|
        format.html # receipts_deliveries.html.erb
        format.json { render json: { :stock => @stock, :receipts => @receipts, :deliveries => @deliveries } }
      end
    end

    private

    def current_product_store
      if !params[:product].blank?
        $product = Product.find(params[:product])
      else
        $product = nil;
      end
      if !params[:store].blank?
        $store = Store.find(params[:store])
      else
        $store = nil;
      end
    end

    # Keeps filter state
    def manage_filter_state
      # products
      if params[:Products]
        session[:Products] = params[:Products]
      elsif session[:Products]
        params[:Products] = session[:Products]
      end
      # stores
      if params[:Stores]
        session[:Stores] = params[:Stores]
      elsif session[:Stores]
        params[:Stores] = session[:Stores]
      end
    end
  end
end
