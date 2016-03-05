require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductCompanyPricesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pp_format_numbers]
    $product = nil
    $company = nil

    # Format numbers properly
    def pp_format_numbers
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end
    def pp_format_numbers_2
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # GET /product_company_prices
    # GET /product_company_prices.json
    def index
      current_product_company
      manage_filter_state
      @product = $product
      @company = $company
      product = nil
      if !$product.nil?
        product = $product.id
      else
        product = params[:Products]
      end
      if !$company.nil?
        company = $company.id
      else
        company = params[:Companies]
      end

      @search = ProductCompanyPrice.search do
        #fulltext params[:search]
        if !product.blank?
          with :product_id, product
        end
        if !company.blank?
          with :company_id, company
        end
        order_by :product_id, :asc
        order_by :company_id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @product_company_prices = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @product_company_prices }
        format.js
      end
    end

    # GET /product_company_prices/1
    # GET /product_company_prices/1.json
    def show
      @breadcrumb = 'read'
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product_company_price }
      end
    end

    # GET /product_company_prices/new
    # GET /product_company_prices/new.json
    def new
      @breadcrumb = 'create'
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.new
      @suppliers = suppliers_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product_company_price }
      end
    end

    # GET /product_company_prices/1/edit
    def edit
      @breadcrumb = 'update'
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.find(params[:id])
      @suppliers = suppliers_dropdown
    end

    # POST /product_company_prices
    # POST /product_company_prices.json
    def create
      @breadcrumb = 'update'
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.new(params[:product_company_price])
      @product_company_price.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @product_company_price.save
          format.html { redirect_to @product_company_price, notice: crud_notice('created', @product_company_price) }
          format.json { render json: @product_company_price, status: :created, location: @product_company_price }
        else
          @suppliers = suppliers_dropdown
          format.html { render action: "new" }
          format.json { render json: @product_company_price.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /product_company_prices/1
    # PUT /product_company_prices/1.json
    def update
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.find(params[:id])
      @product_company_price.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @product_company_price.update_attributes(params[:product_company_price])
          format.html { redirect_to @product_company_price,
                        notice: (crud_notice('updated', @product_company_price) + "#{undo_link(@product_company_price)}").html_safe }
          format.json { head :no_content }
        else
          @suppliers = suppliers_dropdown
          format.html { render action: "edit" }
          format.json { render json: @product_company_price.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /product_company_prices/1
    # DELETE /product_company_prices/1.json
    def destroy
      @product = $product
      @company = $company
      @product_company_price = ProductCompanyPrice.find(params[:id])

      respond_to do |format|
        if @product_company_price.destroy
          format.html { redirect_to product_company_prices_url,
                      notice: (crud_notice('destroyed', @product_company_price) + "#{undo_link(@product_company_price)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to product_company_prices_url, alert: "#{@product_company_price.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @product_company_price.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def suppliers_dropdown
      session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def current_product_company
      if !params[:product].blank?
        $product = Product.find(params[:product])
      else
        $product = nil;
      end
      if !params[:company].blank?
        $company = Supplier.find(params[:company])
      else
        $company = nil;
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
      # companies
      if params[:Companies]
        session[:Companies] = params[:Companies]
      elsif session[:Companies]
        params[:Companies] = session[:Companies]
      end
    end
  end
end
