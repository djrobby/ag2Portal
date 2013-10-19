require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /product_types
    # GET /product_types.json
    def index
      @product_types = ProductType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @product_types }
      end
    end
  
    # GET /product_types/1
    # GET /product_types/1.json
    def show
      @breadcrumb = 'read'
      @product_type = ProductType.find(params[:id])
      #@products = @product_type.products.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product_type }
      end
    end
  
    # GET /product_types/new
    # GET /product_types/new.json
    def new
      @breadcrumb = 'create'
      @product_type = ProductType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product_type }
      end
    end
  
    # GET /product_types/1/edit
    def edit
      @breadcrumb = 'update'
      @product_type = ProductType.find(params[:id])
    end
  
    # POST /product_types
    # POST /product_types.json
    def create
      @breadcrumb = 'create'
      @product_type = ProductType.new(params[:product_type])
      @product_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product_type.save
          format.html { redirect_to @product_type, notice: crud_notice('created', @product_type) }
          format.json { render json: @product_type, status: :created, location: @product_type }
        else
          format.html { render action: "new" }
          format.json { render json: @product_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /product_types/1
    # PUT /product_types/1.json
    def update
      @breadcrumb = 'update'
      @product_type = ProductType.find(params[:id])
      @product_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product_type.update_attributes(params[:product_type])
          format.html { redirect_to @product_type,
                        notice: (crud_notice('updated', @product_type) + "#{undo_link(@product_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /product_types/1
    # DELETE /product_types/1.json
    def destroy
      @product_type = ProductType.find(params[:id])

      respond_to do |format|
        if @product_type.destroy
          format.html { redirect_to product_types_url,
                      notice: (crud_notice('destroyed', @product_type) + "#{undo_link(@product_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to product_types_url, alert: "#{@product_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Store.column_names.include?(params[:sort]) ? params[:sort] : "description"
    end
  end
end
