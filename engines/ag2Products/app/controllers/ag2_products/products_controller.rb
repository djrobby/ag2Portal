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
                                               :pr_update_attachment,
                                               :products_catalog_report,
                                               :receipts_deliveries]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit

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
        data_accessor_for(Product).include = [:product_type, :product_family]
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
      @stocks = @product.stocks.paginate(:page => params[:page], :per_page => per_page).order(:store_id)
      @prices = @product.purchase_prices.paginate(:page => params[:page], :per_page => per_page).order(:supplier_id)
      @prices_by_company = @product.product_company_prices.paginate(:page => params[:page], :per_page => per_page).order(:company_id)

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
      @stores = stores_dropdown if @stores.nil?
      store = params[:Store]
      from = params[:from]
      to = params[:to]
      # OCO
      init_oco if !session[:organization]
      # Receipts, Deliveries & Counts
      @receipts = @product.receipt_note_items.includes(:receipt_note, :store).order('receipt_notes.receipt_date desc, receipt_note_items.id desc').paginate(:page => params[:page], :per_page => per_page)
      @deliveries = @product.delivery_note_items.includes(:delivery_note, :store).order('delivery_notes.delivery_date desc, delivery_note_items.id desc').paginate(:page => params[:page], :per_page => per_page)
      @counts = @product.inventory_count_items.includes(inventory_count: [:store, :inventory_count_type]).order('inventory_counts.count_date desc, inventory_count_items.id desc').paginate(:page => params[:page], :per_page => per_page)
      # Filter by store
      if (!store.nil? && store != "")
        store = store.to_i
        @receipts = @receipts.where('receipt_note_items.store_id = ?', store)
        @deliveries = @deliveries.where('delivery_note_items.store_id = ?', store)
        @counts = @counts.where('inventory_counts.store_id = ?', store)
      end
      # Filter by dates
      if (!from.nil? && from != "") && (!to.nil? && to != "")
        from = from.to_date
        to = to.to_date
        @receipts = @receipts.where('receipt_notes.receipt_date BETWEEN ? AND ?', from, to)
        @deliveries = @deliveries.where('delivery_notes.delivery_date BETWEEN ? AND ?', from, to)
        @counts = @counts.where('inventory_counts.count_date BETWEEN ? AND ?', from, to)
      elsif !from.nil? && from != ""
        from = from.to_date
        @receipts = @receipts.where('receipt_notes.receipt_date >= ?', from)
        @deliveries = @deliveries.where('delivery_notes.delivery_date >= ?', from)
        @counts = @counts.where('inventory_counts.count_date >= ?', from)
      elsif !to.nil? && to != ""
        to = to.to_date
        @receipts = @receipts.where('receipt_notes.receipt_date <= ?', to)
        @deliveries = @deliveries.where('delivery_notes.delivery_date <= ?', to)
        @counts = @counts.where('inventory_counts.count_date <= ?', to)
      end

      # Totals
      @receipts_count = @receipts.count != 0 ? @receipts.count : 1
      @receipts_quantity = @receipts.sum("quantity")
      @receipts_amount = @receipts.sum("(price-receipt_note_items.discount)*quantity")
      @receipts_price_avg = (@receipts_amount == '0' ? 0 : @receipts_amount) / (@receipts_quantity != 0 ? @receipts_quantity : 1)
      @deliveries_count = @deliveries.count != 0 ? @deliveries.count : 1
      @deliveries_quantity = @deliveries.sum("quantity")
      @deliveries_amount = @deliveries.sum("(price-delivery_note_items.discount)*quantity")
      @deliveries_price_avg = (@deliveries_amount == '0' ? 0 : @deliveries_amount) / (@deliveries_quantity != 0 ? @deliveries_quantity : 1)
      @deliveries_costs = @deliveries.sum("cost*quantity")
      @deliveries_cost_avg = (@deliveries_costs == '0' ? 0 : @deliveries_costs) / (@deliveries_quantity != 0 ? @deliveries_quantity : 1)
      @counts_quantity = @counts.sum("quantity")
      @counts_price_avg = @counts.sum("price") / (@counts.count != 0 ? @counts.count : 1)

      respond_to do |format|
        format.html # receipts_deliveries.html.erb
        format.js
      end
    end

    # Products catalog report
    def products_catalog_report
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
        order_by :product_family_id, :asc
        paginate :page => params[:page] || 1, :per_page => Product.count
      end

     @products_catalog_report = @search.results
     @products_catalog_family =  @products_catalog_report

     from = Date.today.to_s

     title = t("activerecord.models.product.few") + "_#{from}"
     respond_to do |format|
      # Render PDF
      if !@products_catalog_report.blank?
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
        format.csv { send_data Product.to_csv(@products_catalog_report),
                     filename: "#{title}.csv",
                     type: 'application/csv',
                     disposition: 'inline' }
      else
        format.csv { redirect_to products_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        format.pdf { redirect_to products_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
      end
     end
    end

    private

    # Can't edit or delete when
    # => User isn't Administrator
    # => User isn't Product_Manager
    def cannot_edit(_product)
      !session[:is_administrator] && !(current_user.has_role? :Product_Manager)
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Product.where('product_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.product_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def stores_dropdown
      _array = []
      _stores = nil
      _store_offices = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _stores = Store.where(office_id: session[:office].to_i)
        _store_offices = StoreOffice.where("office_id = ?", session[:office].to_i)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _stores = Store.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
          _store_offices = StoreOffice.where("office_id IN (?)", _offices)
        else
          _stores = Store.where(company_id: session[:company].to_i)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _stores = Store.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
          _store_offices = StoreOffice.where("office_id IN (?)", _offices)
        else
          _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i) : Store.order
        end
      end

      # Returning founded stores
      ret_array(_array, _stores, 'id')
      ret_array(_array, _store_offices, 'store_id')
      _stores = Store.where(id: _array).order(:name)
    end

    def families_dropdown
      session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)
    end

    # Returns _array from _ret table/model filled with _id attribute
    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
      end
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
      session[:Companies] = nil
    end
  end
end
