require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OffersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:of_totals,
                                               :of_update_description_prices_from_product_store,
                                               :of_update_description_prices_from_product,
                                               :of_update_amount_from_price_or_quantity,
                                               :of_update_charge_account_from_order,
                                               :of_update_charge_account_from_project,
                                               :of_format_numbers,
                                               :of_format_number_4,
                                               :of_current_stock,
                                               :of_update_project_textfields_from_organization,
                                               :of_update_items_table_from_request,
                                               :of_update_request_select_from_supplier,
                                               :of_generate_order]
    # Calculate and format totals properly
    def of_totals
      qty = params[:qty].to_f / 10000
      amount = params[:amount].to_f / 10000
      tax = params[:tax].to_f / 10000
      discount_p = params[:discount_p].to_f / 100
      # Bonus
      discount = discount_p != 0 ? amount * (discount_p / 100) : 0
      # Taxable
      taxable = amount - discount
      # Taxes
      tax = tax - (tax * (discount_p / 100)) if discount_p != 0
      # Total
      total = taxable + tax      
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount = number_with_precision(discount.round(4), precision: 4)
      taxable = number_with_precision(taxable.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discount" => discount.to_s, "taxable" => taxable.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product & store selects
    def of_update_description_prices_from_product_store
      product = params[:product]
      store = params[:store]
      description = ""
      qty = 0
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
        price = @product.reference_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def of_update_description_prices_from_product
      product = params[:product]
      description = ""
      qty = 0
      price = 0
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        price = @product.reference_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def of_update_amount_from_price_or_quantity
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
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s, "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discountp" => discount_p.to_s, "discount" => discount.to_s }

      respond_to do |format|
        format.html # or_update_amount_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update charge account and store text fields at view from work order select
    def of_update_charge_account_from_order
      order = params[:order]
      charge_account_id = 0
      store_id = 0
      if order != '0'
        @order = WorkOrder.find(order)
        @project = @order.project
        @charge_account = @order.charge_account
        charge_account_id = @charge_account.id rescue 0
        @store = @order.store
        store_id = @store.id rescue 0
        if @charge_account.blank?
          @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
        end
        if @store.blank?
          @store = project_stores(@project)
        end
      else
        @charge_account = charge_accounts_dropdown
        @store = stores_dropdown
      end
      @json_data = { "charge_account" => @charge_account, "store" => @store,
                     "charge_account_id" => charge_account_id, "store_id" => store_id }
      render json: @json_data
    end

    # Update work order, charge account and store text fields at view from project select
    def of_update_charge_account_from_project
      project = params[:order]
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? work_orders_dropdown : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
        @store = project_stores(@project)
      else
        @work_order = work_orders_dropdown
        @charge_account = charge_accounts_dropdown
        @store = stores_dropdown
      end
      @json_data = { "work_order" => @work_order, "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Format numbers properly (2)
    def of_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Format numbers properly (4)
    def of_format_number_4
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def of_current_stock
      product = params[:product]
      store = params[:store]
      current_stock = 0
      if product != '0' && store != '0'
        current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
      end
      # Format numbers
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      # Setup JSON
      @json_data = { "stock" => current_stock.to_s }
      render json: @json_data
    end

    # Update project text and other fields at view from organization select
    def of_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @offer_requests = @organization.blank? ? offer_requests_dropdown : @organization.offer_requests.order(:request_no)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : payment_payment_methods(@organization.id)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @suppliers = suppliers_dropdown
        @offer_requests = offer_requests_dropdown
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Offer requests array
      @requests_dropdown = offer_requests_array(@offer_requests)
      # Setup JSON
      @json_data = { "supplier" => @suppliers, "offer_request" => @requests_dropdown,
                     "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products }
      render json: @json_data
    end

    # Update offer items table at view from request items
    def of_update_items_table_from_request
      request = params[:request]
      @request_items = nil
      project_id = 0
      work_order_id = 0
      charge_account_id = 0
      store_id = 0
      payment_method_id = 0
      if request != '0'
        @offer_request = OfferRequest.find(request)
        @request_items = @offer_request.offer_request_items.order(:id) rescue nil
        @projects = @offer_request.blank? ? projects_dropdown : @offer_request.project
        @work_orders = @offer_request.blank? ? work_orders_dropdown : @offer_request.work_order
        @charge_accounts = @offer_request.blank? ? charge_accounts_dropdown : @offer_request.charge_account
        @stores = @offer_request.blank? ? stores_dropdown : @offer_request.store
        @payment_methods = @offer_request.blank? ? payment_methods_dropdown : @offer_request.payment_method
        @products = @offer_request.blank? ? products_dropdown : @offer_request.organization.products.order(:product_code)
        project_id = @projects.id rescue 0
        work_order_id = @work_orders.id rescue 0
        charge_account_id = @charge_accounts.id rescue 0
        store_id = @stores.id rescue 0
        payment_method_id = @payment_methods.id rescue 0
      else
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      @tax_types = TaxType.where('expiration IS NULL').order('description')
      # Offer request items array
      @items_dropdown = offer_request_items_array(@request_items)
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products,
                     "tax_type" => @tax_types, "request_items" => @items_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id }
      render json: @json_data
    end

    # Update offer request select at view from supplier
    def of_update_request_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @offer_requests = @supplier.blank? ? offer_requests_dropdown : @supplier.offer_requests(:request_no)
      else
        @offer_requests = offer_requests_dropdown
      end
      # Offer requests array
      @requests_dropdown = offer_requests_array(@offer_requests)
      # Setup JSON
      @json_data = { "offer_request" => @requests_dropdown }
      render json: @json_data
    end

    # Generate purchase order
    def of_generate_order
      o = params[:offer]
      code = ''
      
      if o != '0'
        offer = Offer.find(o) rescue nil
        offer_items = offer.offer_items rescue nil
        if !offer.nil? && !offer_items.nil?
          # Generate new purchase order no.
          code = (offer.project.nil || offer.project == 0) ? '$err' : po_next_no(project)
          if code != '$err'
            # Attempt save purchase order
            order = PurchaseOrder.new
            order.discount = offer.discount
            order.discount_pct = offer.discount_pct
            order.order_date = DateTime.now
            order.order_no = code
            order.remarks = offer.remarks
            order.supplier_offer_no = offer.offer_no
            order.supplier_id = offer.supplier_id
            order.payment_method_id = offer.payment_method_id
            order.order_status_id = 1
            order.project_id = offer.project_id
            order.offer_id = offer.id
            order.store_id = offer.store_id
            order.work_order_id = offer.work_order_id
            order.charge_account_id = offer.charge_account_id
            order.retention_pct = 0
            order.retention_time = 0
            order.organization_id = offer.organization_id
            order.approver_id = nil
            order.approval_date = nil
            if order.save?
              # Attempt save purchase order items
              offer.offer_items.each do |i|
                item = PurchaseOrderItem.new
                item.code = i.code
                item.delivery_date = i.delivery_date
                item.description = i.description
                item.discount = i.discount
                item.discount_pct = i.discount_pct
                item.quantity = i.quantity
                item.price = i.price
                item.purchase_order_id = order.id
                item.product_id = i.product_id
                item.tax_type_id = i.tax_type_id
                item.project_id = i.project_id
                item.store_id = i.store_id
                item.work_order_id = i.work_order_id
                item.charge_account_id = i.charge_account_id
                if !item.save?
                  # Can't save order item (exit)
                  code = '$write'
                  break
                end   # !item.save?
              end   # do |i|
            else
              # Can't save order
              code = '$write'
            end   # order.save?
          end   # code != '$err'
        else
          # Offer not found
          code = '$err'
        end   # !offer.nil? && !offer_items.nil?
      else
        # Offer 0
        code = '$err'
      end   # o != '0'
      @json_data = { "code" => code }
      render json: @json_data
    end
    
    #
    # Default Methods
    #
    # GET /offers
    # GET /offers.json
    def index
      manage_filter_state
      no = params[:No]
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @suppliers = suppliers_dropdown if @suppliers.nil?
      @projects = projects_dropdown if @projects.nil?
      @work_orders = work_orders_dropdown if @work_orders.nil?

      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      @search = Offer.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          with :offer_no, no
        end
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @offers = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offers }
        format.js
      end
    end
  
    # GET /offers/1
    # GET /offers/1.json
    def show
      @breadcrumb = 'read'
      @offer = Offer.find(params[:id])
      @items = @offer.offer_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @offer }
      end
    end
  
    # GET /offers/new
    # GET /offers/new.json
    def new
      @breadcrumb = 'create'
      @offer = Offer.new
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @offer_requests = offer_requests_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @offer }
      end
    end
  
    # GET /offers/1/edit
    def edit
      @breadcrumb = 'update'
      @offer = Offer.find(params[:id])
      @projects = projects_dropdown_edit(@offer.project)
      @work_orders = @offer.project.blank? ? work_orders_dropdown : @offer.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@offer)
      @stores = work_order_store(@offer)
      @suppliers = @offer.organization.blank? ? suppliers_dropdown : @offer.organization.suppliers(:supplier_code)
      @offer_requests = @offer.organization.blank? ? offer_requests_dropdown : @offer.organization.offer_requests(:request_no)
      @payment_methods = @offer.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@offer.organization_id)
      @products = @offer.organization.blank? ? products_dropdown : @offer.organization.products(:product_code)
    end
  
    # POST /offers
    # POST /offers.json
    def create
      @breadcrumb = 'create'
      @offer = Offer.new(params[:offer])
      @offer.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer.save
          format.html { redirect_to @offer, notice: crud_notice('created', @offer) }
          format.json { render json: @offer, status: :created, location: @offer }
        else
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @offer_requests = offer_requests_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /offers/1
    # PUT /offers/1.json
    def update
      @breadcrumb = 'update'
      @offer = Offer.find(params[:id])
      @offer.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer.update_attributes(params[:offer])
          format.html { redirect_to @offer,
                        notice: (crud_notice('updated', @offer) + "#{undo_link(@offer)}").html_safe }
          format.json { head :no_content }
        else
          @projects = projects_dropdown_edit(@offer.project)
          @work_orders = @offer.project.blank? ? work_orders_dropdown : @offer.project.work_orders.order(:order_no)
          @charge_accounts = work_order_charge_account(@offer)
          @stores = work_order_store(@offer)
          @suppliers = @offer.organization.blank? ? suppliers_dropdown : @offer.organization.suppliers(:supplier_code)
          @offer_requests = @offer.organization.blank? ? offer_requests_dropdown : @offer.organization.offer_requests(:request_no)
          @payment_methods = @offer.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@offer.organization_id)
          @products = @offer.organization.blank? ? products_dropdown : @offer.organization.products(:product_code)
          format.html { render action: "edit" }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /offers/1
    # DELETE /offers/1.json
    def destroy
      @offer = Offer.find(params[:id])

      respond_to do |format|
        if @offer.destroy
          format.html { redirect_to offers_url,
                      notice: (crud_notice('destroyed', @offer) + "#{undo_link(@offer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to offers_url, alert: "#{@offer.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
        end
      end
    end

    private
    
    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end
    
    def project_stores(_project)
      if !_project.company.blank? && !_project.office.blank?
        _store = Store.where("(company_id = ? AND office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id, _project.office.id).order(:name)
      elsif !_project.company.blank? && _project.office.blank?
        _store = Store.where("(company_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.company.id).order(:name)
      elsif _project.company.blank? && !_project.office.blank?
        _store = Store.where("(office_id = ?) OR (company_id IS NULL AND NOT supplier_id IS NULL)", _project.office.id).order(:name)
      else
        _store = stores_dropdown
      end
      _store
    end

    def work_order_charge_account(_order)
      if _order.work_order.blank? || _order.work_order.charge_account.blank?
        _charge_account = _order.project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(_order.project_id)
      else
        _charge_account = ChargeAccount.where("id = ?", _order.work_order.charge_account)
      end
      _charge_account
    end

    def work_order_store(_order)
      if _order.work_order.blank? || _order.work_order.store.blank?
        _store = _order.project.blank? ? stores_dropdown : project_stores(_order.project)
      else
        _store = Store.where("id = ?", _order.work_order.store)
      end
      _store
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def suppliers_dropdown
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def charge_accounts_dropdown
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
    end

    def stores_dropdown
      _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def work_orders_dropdown
      _orders = session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def payment_methods_dropdown
      _methods = session[:organization] != '0' ? payment_payment_methods(session[:organization].to_i) : payment_payment_methods(0)
    end
    
    def payment_payment_methods(_organization)
      if _organization != 0
        _methods = PaymentMethod.where("(flow = 3 OR flow = 2) AND organization_id = ?", _organization).order(:description)
      else
        _methods = PaymentMethod.where("flow = 3 OR flow = 2").order(:description)
      end
      _methods
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end    

    def offer_requests_dropdown
      session[:organization] != '0' ? OfferRequest.where(organization_id: session[:organization].to_i).order(:request_no) : OfferRequest.order(:request_no)
    end    
    
    def offer_requests_array(_requests)
      _requests_array = []
      _requests.each do |i|
        _requests_array = _requests_array << [i.id, i.full_no, formatted_date(i.request_date)] 
      end
      _requests_array
    end
    
    def offer_request_items_array(_items)
      _items_array = []
      if !_items.nil?
        _items.each do |i|
          _items_array = _items_array << [i.id, i.product_id, i.description, i.quantity, i.price, i.amount, i.tax_type_id,
                                          i.tax, i.work_order_id, i.project_id, i.charge_account_id, i.store_id] 
        end
      end
      _items_array
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
      # supplier
      if params[:Supplier]
        session[:Supplier] = params[:Supplier]
      elsif session[:Supplier]
        params[:Supplier] = session[:Supplier]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # order
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
    end
  end
end
