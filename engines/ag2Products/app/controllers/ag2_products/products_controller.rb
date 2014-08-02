require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_code_textfield,
                                               :pr_format_amount,
                                               :pr_markup]
    # Update product code at view (generate_code_btn)
    def update_code_textfield
      family = params[:id]
      code = ''

      # Builds code, if possible
      if family == '$'
        code = '$err'
      else
        family = family.to_s if family.is_a? Fixnum
        family = family.rjust(4, '0')
        last_product_code = Product.where("product_code LIKE ?", "#{family}%").order('product_code').maximum('product_code')
        if last_product_code.nil?
          code = family + '000001'
        else
          last_product_code = last_product_code[4..9].to_i + 1
          code = family + last_product_code.to_s.rjust(6, '0')
        end
      end
      @json_data = { "code" => code }

      respond_to do |format|
        format.html # update_code_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Format amount properly
    def pr_format_amount
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Format percentage properly and calculate sell price
    def pr_markup
      markup = params[:markup].to_f / 100
      sell = params[:sell].to_f / 10000
      reference = params[:reference].to_f / 10000
      if markup != 0
        sell = reference * (1 + (markup / 100))
      end
      markup = number_with_precision(markup.round(2), precision: 2)
      sell = number_with_precision(sell.round(4), precision: 4)
      @json_data = { "markup" => markup.to_s, "sell" => sell.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /products
    # GET /products.json
    def index
      manage_filter_state
      type = params[:Type]
      family = params[:Family]
      measure = params[:Measure]
      manufacturer = params[:Manufacturer]
      tax = params[:Tax]
      letter = params[:letter]
      if !session[:organization]
        init_oco
      end
  
      @search = Product.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          with(:main_description).starting_with(letter)
        end
        if !type.blank?
          with :product_type_id, type
        end
        if !family.blank?
          with :product_family_id, family
        end
        if !measure.blank?
          with :measure_id, measure
        end
        if !manufacturer.blank?
          with :manufacturer_id, manufacturer
        end
        if !tax.blank?
          with :tax_type_id, tax
        end
        order_by :product_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @products = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @products }
      end
    end
  
    # GET /products/1
    # GET /products/1.json
    def show
      reset_stock_prices_filter
      @breadcrumb = 'read'
      @product = Product.find(params[:id])
      @stocks = @product.stocks.paginate(:page => params[:page], :per_page => per_page).order('store_id')
      @prices = @product.purchase_prices.paginate(:page => params[:page], :per_page => per_page).order('supplier_id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product }
      end
    end
  
    # GET /products/new
    # GET /products/new.json
    def new
      @breadcrumb = 'create'
      @product = Product.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product }
      end
    end
  
    # GET /products/1/edit
    def edit
      @breadcrumb = 'update'
      @product = Product.find(params[:id])
    end
  
    # POST /products
    # POST /products.json
    def create
      @breadcrumb = 'update'
      @product = Product.new(params[:product])
      @product.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product.save
          format.html { redirect_to @product, notice: crud_notice('created', @product) }
          format.json { render json: @product, status: :created, location: @product }
        else
          format.html { render action: "new" }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /products/1
    # PUT /products/1.json
    def update
      @breadcrumb = 'update'
      @product = Product.find(params[:id])
      @product.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product.update_attributes(params[:product])
          format.html { redirect_to @product,
                        notice: (crud_notice('updated', @product) + "#{undo_link(@product)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /products/1
    # DELETE /products/1.json
    def destroy
      @product = Product.find(params[:id])

      respond_to do |format|
        if @product.destroy
          format.html { redirect_to products_url,
                      notice: (crud_notice('destroyed', @product) + "#{undo_link(@product)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to products_url, alert: "#{@product.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @product.errors, status: :unprocessable_entity }
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
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end
      # family
      if params[:Family]
        session[:Family] = params[:Family]
      elsif session[:Family]
        params[:Family] = session[:Family]
      end
      # measure
      if params[:Measure]
        session[:Measure] = params[:Measure]
      elsif session[:Measure]
        params[:Measure] = session[:Measure]
      end
      # manufacturer
      if params[:Manufacturer]
        session[:Manufacturer] = params[:Manufacturer]
      elsif session[:Manufacturer]
        params[:Manufacturer] = session[:Manufacturer]
      end
      # tax
      if params[:Tax]
        session[:Tax] = params[:Tax]
      elsif session[:Tax]
        params[:Tax] = session[:Tax]
      end
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end

    def reset_stock_prices_filter
      session[:Products] = nil
      session[:Stores] = nil      
      session[:Suppliers] = nil      
    end
  end
end
