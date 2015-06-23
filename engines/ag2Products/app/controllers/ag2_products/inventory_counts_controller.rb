require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryCountsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /inventory_counts
    # GET /inventory_counts.json
    def index
      manage_filter_state
      no = params[:No]
      store = params[:Store]
      family = params[:Family]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @stores = stores_dropdown if @stores.nil?
      @families = families_dropdown if @families.nil?

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = DeliveryNote.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :count_no, no
          else
            with(:count_no).starting_with(no)
          end
        end
        if !store.blank?
          with :store_id, store
        end
        if !family.blank?
          with :product_family_id, family
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @inventory_counts = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inventory_counts }
        format.js
      end
    end
  
    # GET /inventory_counts/1
    # GET /inventory_counts/1.json
    def show
      @breadcrumb = 'read'
      @inventory_count = InventoryCount.find(params[:id])
      @items = @inventory_count.inventory_count_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inventory_count }
      end
    end
  
    # GET /inventory_counts/new
    # GET /inventory_counts/new.json
    def new
      @breadcrumb = 'create'
      @inventory_count = InventoryCount.new
      @stores = stores_dropdown
      @families = families_dropdown
      @products = products_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_count }
      end
    end
  
    # GET /inventory_counts/1/edit
    def edit
      @breadcrumb = 'update'
      @inventory_count = InventoryCount.find(params[:id])
      @stores = @inventory_count.organization.blank? ? stores_dropdown : @inventory_count.organization.stores(:name)
      @families = @inventory_count.organization.blank? ? families_dropdown : @inventory_count.organization.product_families(:family_code)
      @products = @inventory_count.organization.blank? ? products_dropdown : @inventory_count.organization.products(:product_code)
    end
  
    # POST /inventory_counts
    # POST /inventory_counts.json
    def create
      @breadcrumb = 'create'
      @inventory_count = InventoryCount.new(params[:inventory_count])
      @inventory_count.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @inventory_count.save
          format.html { redirect_to @inventory_count, notice: crud_notice('created', @inventory_count) }
          format.json { render json: @inventory_count, status: :created, location: @inventory_count }
        else
          @stores = stores_dropdown
          @families = families_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /inventory_counts/1
    # PUT /inventory_counts/1.json
    def update
      @breadcrumb = 'update'
      @inventory_count = InventoryCount.find(params[:id])
      @inventory_count.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @inventory_count.update_attributes(params[:inventory_count])
          format.html { redirect_to @inventory_count,
                        notice: (crud_notice('updated', @inventory_count) + "#{undo_link(@inventory_count)}").html_safe }
          format.json { head :no_content }
        else
          @stores = @inventory_count.organization.blank? ? stores_dropdown : @inventory_count.organization.stores(:name)
          @families = @inventory_count.organization.blank? ? families_dropdown : @inventory_count.organization.product_families(:family_code)
          @products = @inventory_count.organization.blank? ? products_dropdown : @inventory_count.organization.products(:product_code)
          format.html { render action: "edit" }
          format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventory_counts/1
    # DELETE /inventory_counts/1.json
    def destroy
      @inventory_count = InventoryCount.find(params[:id])

      respond_to do |format|
        if @inventory_count.destroy
          format.html { redirect_to inventory_counts_url,
                      notice: (crud_notice('destroyed', @inventory_count) + "#{undo_link(@inventory_count)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to inventory_counts_url, alert: "#{@inventory_count.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
        end
      end
    end
    
    private

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      InventoryCount.where('count_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.count_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end
    
    def families_dropdown
      _families = session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)  
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end    
  end
end
