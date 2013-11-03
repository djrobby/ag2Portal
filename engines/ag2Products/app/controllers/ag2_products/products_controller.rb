require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /products
    # GET /products.json
    def index
      @products = Product.all
  
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
      #@stocks = @product.stocks.paginate(:page => params[:page], :per_page => per_page).order('product_code')
      #@prices = @product.purchase_prices.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
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
