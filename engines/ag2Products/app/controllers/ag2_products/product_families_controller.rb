require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductFamiliesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pf_format_numbers]
    # Helper methods for sorting
    helper_method :sort_column

    # Format numbers properly
    def pf_format_numbers
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }

      respond_to do |format|
        format.html # pf_format_numbers.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /product_families
    # GET /product_families.json
    def index
      @product_families = ProductFamily.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @product_families }
      end
    end
  
    # GET /product_families/1
    # GET /product_families/1.json
    def show
      @breadcrumb = 'read'
      @product_family = ProductFamily.find(params[:id])
      @products = @product_family.products.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product_family }
      end
    end
  
    # GET /product_families/new
    # GET /product_families/new.json
    def new
      @breadcrumb = 'create'
      @product_family = ProductFamily.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product_family }
      end
    end
  
    # GET /product_families/1/edit
    def edit
      @breadcrumb = 'update'
      @product_family = ProductFamily.find(params[:id])
    end
  
    # POST /product_families
    # POST /product_families.json
    def create
      @breadcrumb = 'create'
      @product_family = ProductFamily.new(params[:product_family])
      @product_family.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product_family.save
          format.html { redirect_to @product_family, notice: crud_notice('created', @product_family) }
          format.json { render json: @product_family, status: :created, location: @product_family }
        else
          format.html { render action: "new" }
          format.json { render json: @product_family.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /product_families/1
    # PUT /product_families/1.json
    def update
      @breadcrumb = 'update'
      @product_family = ProductFamily.find(params[:id])
      @product_family.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @product_family.update_attributes(params[:product_family])
          format.html { redirect_to @product_family,
                        notice: (crud_notice('updated', @product_family) + "#{undo_link(@product_family)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product_family.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /product_families/1
    # DELETE /product_families/1.json
    def destroy
      @product_family = ProductFamily.find(params[:id])
  
      respond_to do |format|
        if @product_family.destroy
          format.html { redirect_to product_families_url,
                      notice: (crud_notice('destroyed', @product_family) + "#{undo_link(@product_family)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to product_families_url, alert: "#{@product_family.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @product_family.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ProductFamily.column_names.include?(params[:sort]) ? params[:sort] : "family_code"
    end
  end
end
