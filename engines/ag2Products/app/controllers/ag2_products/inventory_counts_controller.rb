require_dependency "ag2_products/application_controller"

module Ag2Products
  class InventoryCountsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ic_totals,
                                               :ic_update_family_select_from_store,
                                               :ic_generate_count,
                                               :ic_generate_no,
                                               :ic_approve_count,
                                               :ic_update_from_product_store,
                                               :ic_update_stocks_from_quantity,
                                               :ic_update_from_organization]
    # Calculate and format totals properly
    def ic_totals
      qty = params[:qty].to_f / 10000
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s }
      render json: @json_data
    end

    # Update product family select at view from store
    def ic_update_family_select_from_store
      store = params[:store]
      if store != '0'
        @store = Store.find(store)
        @product_families = @store.blank? ? families_dropdown : ProductFamily.by_store(@store)
      else
        @product_families = families_dropdown
      end
      # Setup JSON
      @json_data = { "product_families" => @product_families }
      render json: @json_data
    end

    # Generate new inventory count from store & family
    def ic_generate_count
      store = params[:store]
      family = params[:family]
      count = nil
      count_item = nil
      code = ''

      if store != '0' && family != '0'
        stocks = Stock.find_by_store_and_family(store, family) rescue nil
        if !stocks.nil?
          # Try save new inventory count
          inventory_count = InventoryCount.new
          inventory_count.count_no = ic_next_no(store)
          inventory_count.count_date = Time.now.to_date
          inventory_count.inventory_count_type_id = 2
          inventory_count.store_id = store
          inventory.count.product_family_id = family
          inventory_count.organization_id = Store.find(store).organization_id rescue nil
          inventory_count.created_by = current_user.id if !current_user.nil?
          if inventory_count.save
            # Try to save new inventory count items
            stocks.each do |i|
              inventory_count_item = InventoryCountItem.new
              inventory_count_item.inventory_count_id = inventory_count.id
              inventory_count_item.product_id = i.product_id
              inventory_count_item.quantity = 0
              inventory_count_item.created_by = current_user.id if !current_user.nil?
              if !inventory_count_item.save
                # Can't save offer item (exit)
                code = '$write'
                break
              end   # !inventory_count_item.save
            end   # do |i|
          else
            # Can't save inventory count
            code = '$write'
          end   # inventory_count.save
        else
          # Stocks not found
          code = '$err'
        end   # !stocks.nil?
      else
        # Store or Family 0
        code = '$err'
      end   # store != '0' && family != '0'
      if code == ''
        code = I18n.t("ag2_products.inventory_counts.generate_count_ok", var: inventory_count.id.to_s)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update inventory count number at view (generate_code_btn)
    def ic_generate_no
      store = params[:store]

      # Builds no, if possible
      code = store == '$' ? '$err' : ic_next_no(store)
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Approve inventory count
    def ic_approve_count
      _order = params[:order]
      code = '$err'
      _approver_id = nil
      _approver = nil
      _approval_date = nil

      order = PurchaseOrder.find(_order)
      if !order.nil?
        if order.approver_id.blank?
          # Can approve offer
          _approver_id = current_user.id
          _approval_date = DateTime.now
          order.approver_id = _approver_id
          order.approval_date = _approval_date
          # Attempt approve
          if order.save
            # Success
            code = '$ok'
          else
            # Can't save purchase order
            code = '$write'
          end
        else
          # This order is already approved
          code = '$warn'
        end
      else
        # Purchase order not found
        code = '$err'
      end
      # Approver data
      if !_approver_id.nil?
        _approver = User.find(_approver_id).email        
      end
      # Approval date
      if !_approval_date.nil?
        _approval_date = formatted_timestamp(_approval_date)
      end

      @json_data = { "code" => code, "approver" => _approver, "approval_date" => _approval_date }
      render json: @json_data
    end

    def ic_update_from_product_store
      product = params[:product]
      store = params[:store]
      description = ""
      qty = 0
      cost = 0
      costs = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      current_stock = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        cost = @product.reference_price
        costs = qty * cost
        price = @product.sell_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "description" => description,
                     "cost" => cost.to_s, "costs" => costs.to_s,
                     "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }
      render json: @json_data
    end

    def ic_update_stocks_from_quantity
      cost = params[:cost].to_f / 10000
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      discount_p = params[:discount_p].to_f / 100
      discount = params[:discount].to_f / 10000
      product = params[:product]
      if tax_type.blank? || tax_type == "0"
        if !product.blank? && product != "0"
          tax_type = Product.find(product).tax_type.id
        else
          tax_type = TaxType.where('expiration IS NULL').order('id').first.id
        end
      end
      tax = TaxType.find(tax_type).tax
      if discount_p > 0
        discount = price * (discount_p / 100)
      end
      amount = qty * (price - discount)
      costs = qty * cost
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s, "cost" => cost.to_s, "costs" => costs.to_s, 
                     "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discountp" => discount_p.to_s, "discount" => discount.to_s }
      render json: @json_data
    end

    def ic_update_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @clients = @organization.blank? ? clients_dropdown : @organization.clients.order(:client_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : collection_payment_methods(@organization.id)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @clients = clients_dropdown
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "client" => @clients, "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown }
      render json: @json_data
    end

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
      # Approvers
      @is_approver = company_approver(@inventory_count, @inventory_count.store.company, current_user.id) ||
                     office_approver(@inventory_count, @inventory_count.store.office, current_user.id)
  
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
    
    def families_array(_families)
      _array = []
      _families.each do |i|
        _requests_array = _array << [i.id, i.family_code, i.name[0,40]] 
      end
      _array
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
      # store
      if params[:Store]
        session[:Store] = params[:Store]
      elsif session[:Store]
        params[:Store] = session[:Store]
      end
      # family
      if params[:Family]
        session[:Family] = params[:Family]
      elsif session[:Family]
        params[:Family] = session[:Family]
      end
    end
end
