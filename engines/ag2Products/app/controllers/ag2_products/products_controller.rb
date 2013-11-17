require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_code_textfield]
    
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
          code = family + '-000001'
        else
          last_product_code = last_product_code.split("-").last.to_i + 1
          code = family + '-' + last_product_code.to_s.rjust(6, '0')
        end
      end
      @json_data = { "code" => code }

      respond_to do |format|
        format.html # update_code_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /products
    # GET /products.json
    def index
      type = params[:Type]
      family = params[:Family]
      measure = params[:Measure]
      manufacturer = params[:Manufacturer]
      tax = params[:Tax]
      letter = params[:letter]
  
      @search = Product.search do
        fulltext params[:search]
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
      if letter.blank? || letter == "%"
        @products = @search.results
      else
        @products = Product.where("main_description LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('product_code')
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @products }
      end
    end
  
    # GET /products/1
    # GET /products/1.json
    def show
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
  end
end
