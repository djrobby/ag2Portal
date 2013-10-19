require_dependency "ag2_products/application_controller"

module Ag2Products
  class StoresController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /stores
    # GET /stores.json
    def index
      @stores = Store.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @stores }
      end
    end
  
    # GET /stores/1
    # GET /stores/1.json
    def show
      @breadcrumb = 'read'
      @store = Store.find(params[:id])
      #@products = @store.products.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @store }
      end
    end
  
    # GET /stores/new
    # GET /stores/new.json
    def new
      @breadcrumb = 'create'
      @store = Store.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @store }
      end
    end
  
    # GET /stores/1/edit
    def edit
      @breadcrumb = 'update'
      @store = Store.find(params[:id])
    end
  
    # POST /stores
    # POST /stores.json
    def create
      @breadcrumb = 'create'
      @store = Store.new(params[:store])
      @store.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @store.save
          format.html { redirect_to @store, notice: crud_notice('created', @store) }
          format.json { render json: @store, status: :created, location: @store }
        else
          format.html { render action: "new" }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /stores/1
    # PUT /stores/1.json
    def update
      @breadcrumb = 'update'
      @store = Store.find(params[:id])
      @store.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @store.update_attributes(params[:store])
          format.html { redirect_to @store,
                        notice: (crud_notice('updated', @store) + "#{undo_link(@store)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /stores/1
    # DELETE /stores/1.json
    def destroy
      @store = Store.find(params[:id])
  
      respond_to do |format|
        if @store.destroy
          format.html { redirect_to stores_url,
                      notice: (crud_notice('destroyed', @store) + "#{undo_link(@store)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to stores_url, alert: "#{@store.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Store.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
