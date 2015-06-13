require_dependency "ag2_products/application_controller"

module Ag2Products
  class ProductsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pr_update_code_textfield,
                                               :pr_format_amount,
                                               :pr_markup,
                                               :pr_update_family_textfield_from_organization,
                                               :pr_update_attachment]
    # Public attachment for drag&drop
    $attachment = nil
  
    # Update attached file from drag&drop
    def pr_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment.avatar = params[:file]
      $attachment.id = 1
      #$attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end

    # Update product code at view (generate_code_btn)
    def pr_update_code_textfield
      family = params[:fam]
      organization = params[:org]

      # Builds no, if possible
      if family == '$' || organization == '$'
        code = '$err'
      else
        code = pt_next_code(organization, family)
      end
      @json_data = { "code" => code }
      render json: @json_data
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
    
    # Update family text field at view from organization select
    def pr_update_family_textfield_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @product_families = @organization.blank? ? families_dropdown : @organization.product_families.order(:family_code)
      else
        @offices = families_dropdown
      end
      @json_data = { "families" => @product_families }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /products
    # GET /products.json
    def index
      manage_filter_state
      no = params[:No]
      type = params[:Type]
      family = params[:Family]
      measure = params[:Measure]
      manufacturer = params[:Manufacturer]
      tax = params[:Tax]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @product_families = families_dropdown if @product_families.nil?
  
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = Product.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          with(:main_description).starting_with(letter)
        end
        if !no.blank?
          if no.class == Array
            with :product_code, no
          else
            with(:product_code).starting_with(no)
          end
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
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @products = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @products }
        format.js
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
      @product_families = families_dropdown
      $attachment = Attachment.new
      destroy_attachment
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @product }
      end
    end
  
    # GET /products/1/edit
    def edit
      @breadcrumb = 'update'
      @product = Product.find(params[:id])
      @product_families = @product.organization.blank? ? families_dropdown : @product.organization.product_families.order(:name)
      $attachment = Attachment.new
      destroy_attachment
    end
  
    # POST /products
    # POST /products.json
    def create
      @breadcrumb = 'update'
      @product = Product.new(params[:product])
      @product.created_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if @product.image.blank? && !$attachment.avatar.blank?
        @product.image = $attachment.avatar
      end
  
      respond_to do |format|
        if @product.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @product, notice: crud_notice('created', @product) }
          format.json { render json: @product, status: :created, location: @product }
        else
          $attachment.destroy
          $attachment = Attachment.new
          @product_families = families_dropdown
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
      # Should use attachment from drag&drop?
      if !$attachment.avatar.blank? && $attachment.updated_at > @product.updated_at
        @product.image = $attachment.avatar
      end
  
      respond_to do |format|
        if @product.update_attributes(params[:product])
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @product,
                        notice: (crud_notice('updated', @product) + "#{undo_link(@product)}").html_safe }
          format.json { head :no_content }
        else
          $attachment.destroy
          $attachment = Attachment.new
          @product_families = @product.organization.blank? ? families_dropdown : @product.organization.product_families.order(:name)
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

    # GET /receipts_deliveries
    # GET /receipts_deliveries.json
    def receipts_deliveries
      @product = Product.find(params[:id])
      # OCO
      init_oco if !session[:organization]
      # Receipts & Deliveries
      #@receipts = product.receipt_note_items.includes(:receipt_note).order(:receipt_date)
      @receipts = @product.receipt_note_items.joins(:receipt_note).order('receipt_date desc').paginate(:page => params[:page], :per_page => per_page)
      @deliveries = @product.delivery_note_items.joins(:delivery_note).order('delivery_date desc').paginate(:page => params[:page], :per_page => per_page)

      respond_to do |format|
        format.html # receipts_deliveries.html.erb
        format.json { render json: { :product => @product, :receipts => @receipts, :deliveries => @deliveries } }
      end
    end

    private

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Product.where('product_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.product_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end
    
    def families_dropdown
      _families = session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)  
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # no
      if params[:No]
        session[:No] = params[:No]
      elsif session[:No]
        params[:No] = session[:No]
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
