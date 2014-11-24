require_dependency "ag2_products/application_controller"

module Ag2Products
  class ManufacturersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /manufacturers
    # GET /manufacturers.json
    def index
      manage_filter_state
      @manufacturers = Manufacturer.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @manufacturers }
        format.js
      end
    end
  
    # GET /manufacturers/1
    # GET /manufacturers/1.json
    def show
      @breadcrumb = 'read'
      @manufacturer = Manufacturer.find(params[:id])
      @products = @manufacturer.products.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @manufacturer }
      end
    end
  
    # GET /manufacturers/new
    # GET /manufacturers/new.json
    def new
      @breadcrumb = 'create'
      @manufacturer = Manufacturer.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @manufacturer }
      end
    end
  
    # GET /manufacturers/1/edit
    def edit
      @breadcrumb = 'update'
      @manufacturer = Manufacturer.find(params[:id])
    end
  
    # POST /manufacturers
    # POST /manufacturers.json
    def create
      @breadcrumb = 'create'
      @manufacturer = Manufacturer.new(params[:manufacturer])
      @manufacturer.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @manufacturer.save
          format.html { redirect_to @manufacturer, notice: crud_notice('created', @manufacturer) }
          format.json { render json: @manufacturer, status: :created, location: @manufacturer }
        else
          format.html { render action: "new" }
          format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /manufacturers/1
    # PUT /manufacturers/1.json
    def update
      @breadcrumb = 'update'
      @manufacturer = Manufacturer.find(params[:id])
      @manufacturer.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @manufacturer.update_attributes(params[:manufacturer])
          format.html { redirect_to @manufacturer,
                        notice: (crud_notice('updated', @manufacturer) + "#{undo_link(@manufacturer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /manufacturers/1
    # DELETE /manufacturers/1.json
    def destroy
      @manufacturer = Manufacturer.find(params[:id])
      @manufacturer.destroy
  
      respond_to do |format|
        format.html { redirect_to manufacturers_url,
                      notice: (crud_notice('destroyed', @manufacturer) + "#{undo_link(@manufacturer)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Manufacturer.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    # Keeps filter state
    def manage_filter_state
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end
  end
end
