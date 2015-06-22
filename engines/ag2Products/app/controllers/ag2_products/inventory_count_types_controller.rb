require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryCountTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /inventory_count_types
    # GET /inventory_count_types.json
    def index
      manage_filter_state
      @inventory_count_types = InventoryCountType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inventory_count_types }
        format.js
      end
    end
  
    # GET /inventory_count_types/1
    # GET /inventory_count_types/1.json
    def show
      @breadcrumb = 'read'
      @inventory_count_type = InventoryCountType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inventory_count_type }
      end
    end
  
    # GET /inventory_count_types/new
    # GET /inventory_count_types/new.json
    def new
      @breadcrumb = 'create'
      @inventory_count_type = InventoryCountType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_count_type }
      end
    end
  
    # GET /inventory_count_types/1/edit
    def edit
      @breadcrumb = 'update'
      @inventory_count_type = InventoryCountType.find(params[:id])
    end
  
    # POST /inventory_count_types
    # POST /inventory_count_types.json
    def create
      @breadcrumb = 'create'
      @inventory_count_type = InventoryCountType.new(params[:inventory_count_type])
      @inventory_count_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @inventory_count_type.save
          format.html { redirect_to @inventory_count_type, notice: crud_notice('created', @inventory_count_type) }
          format.json { render json: @inventory_count_type, status: :created, location: @inventory_count_type }
        else
          format.html { render action: "new" }
          format.json { render json: @inventory_count_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /inventory_count_types/1
    # PUT /inventory_count_types/1.json
    def update
      @breadcrumb = 'update'
      @inventory_count_type = InventoryCountType.find(params[:id])
      @inventory_count_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @inventory_count_type.update_attributes(params[:inventory_count_type])
          format.html { redirect_to @inventory_count_type,
                        notice: (crud_notice('updated', @inventory_count_type) + "#{undo_link(@inventory_count_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @inventory_count_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventory_count_types/1
    # DELETE /inventory_count_types/1.json
    def destroy
      @inventory_count_type = InventoryCountType.find(params[:id])

      respond_to do |format|
        if @inventory_count_type.destroy
          format.html { redirect_to inventory_count_types_url,
                      notice: (crud_notice('destroyed', @inventory_count_type) + "#{undo_link(@inventory_count_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to inventory_count_types_url, alert: "#{@inventory_count_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @inventory_count_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      InventoryCountType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
