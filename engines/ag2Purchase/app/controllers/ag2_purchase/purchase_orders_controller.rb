require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PurchaseOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:po_update_description_prices_from_product_store,
                                               :po_update_description_prices_from_product,
                                               :po_update_charge_account_from_order,
                                               :po_update_charge_account_from_project,
                                               :po_update_amount_from_price_or_quantity,
                                               :po_update_offer_select_from_supplier,
                                               :po_update_selects_from_offer,
                                               :po_format_numbers,
                                               :po_totals,
                                               :po_current_stock,
                                               :po_update_project_textfields_from_organization,
                                               :po_generate_no,
                                               :po_product_stock,
                                               :po_product_all_stocks,
                                               :po_check_stock_before_approve,
                                               :po_approve_order,
                                               :po_update_addresses_from_store,
                                               :purchase_order_form,
                                               :send_purchase_order_form]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit

    # Update addresses at view from store select
    def po_update_addresses_from_store
      store = params[:store]
      address_1 = ""
      address_2 = ""
      phones = ""
      if store != '0'
        store = Store.find(store)
        address_1 = store.address_1 rescue ""
        address_2 = store.address_2 rescue ""
        phones = store.phone_and_fax rescue ""
      end
      # Setup JSON
      @json_data = { "address_1" => address_1, "address_2" => address_2, "phones" => phones }
      render json: @json_data
    end

    # Update offer select at view from supplier select
    def po_update_offer_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @offers = @supplier.blank? ? offers_dropdown : @supplier.offers.order(:supplier_id, :offer_no, :id)
      else
        @offers = offers_dropdown
      end
      # Offers array
      @offers_dropdown = offers_array(@offers)
      # Setup JSON
      @json_data = { "offer" => @offers_dropdown }
      render json: @json_data
    end

    # Update selects at view from offer
    def po_update_selects_from_offer
      o = params[:o]
      project_id = 0
      work_order_id = 0
      charge_account_id = 0
      store_id = 0
      payment_method_id = 0
      if o != '0'
        @offer = Offer.find(o)
        @projects = @offer.blank? ? projects_dropdown : @offer.project
        @work_orders = @offer.blank? ? work_orders_dropdown : @offer.work_order
        @charge_accounts = @offer.blank? ? charge_accounts_dropdown : @offer.charge_account
        @stores = @offer.blank? ? stores_dropdown : @offer.store
        @payment_methods = @offer.blank? ? payment_methods_dropdown : @offer.payment_method
        @products = @offer.blank? ? products_dropdown : @offer.organization.products.order(:product_code)
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
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id }
      render json: @json_data
    end

    # Calculate and format totals properly
    def po_totals
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
    def po_update_description_prices_from_product_store
      product = params[:product]
      store = params[:store]
      supplier = params[:supplier]
      tbl = params[:tbl]
      description = ""
      qty = 0
      price = 0
      discount_p = 0
      discount = 0
      code = ""
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      current_stock = 0
      product_stock = 0
      if product != '0'
        @product = Product.find(product)
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        # Use purchase price, if any. Otherwise, the reference price
        #price = @product.reference_price
        price, discount_p, code = product_price_to_apply(@product, supplier)
        if discount_p > 0
          discount = price * (discount_p / 100)
        end
        amount = qty * (price - discount)
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
        product_stock = @product.not_jit_stock
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      product_stock = number_with_precision(product_stock.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id,
                     "stock" => current_stock.to_s, "product_stock" => product_stock.to_s,
                     "discountp" => discount_p, "discount" => discount, "code" => code, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def po_update_description_prices_from_product
      product = params[:product]
      supplier = params[:supplier]
      description = ""
      qty = 0
      price = 0
      discount_p = 0
      discount = 0
      code = ""
      amount = 0
      tax_type_id = 0
      tax_type_tax = 0
      tax = 0
      if product != '0'
        @product = Product.find(product)
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        # Use purchase price, if any. Otherwise, the reference price
        price, discount_p, code = product_price_to_apply(@product, supplier)
        if discount_p > 0
          discount = price * (discount_p / 100)
        end
        amount = qty * (price - discount)
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id,
                     "discountp" => discount_p, "discount" => discount, "code" => code }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def po_update_amount_from_price_or_quantity
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      discount_p = params[:discount_p].to_f / 100
      discount = params[:discount].to_f / 10000
      product = params[:product]
      tbl = params[:tbl]
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
                     "discountp" => discount_p.to_s, "discount" => discount.to_s, "tbl" => tbl.to_s }

      respond_to do |format|
        format.html # po_update_amount_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update charge account and store text fields at view from work order select
    def po_update_charge_account_from_order
      order = params[:order]
      projects = projects_dropdown
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
          @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        end
        if @store.blank?
          @store = project_stores(@project)
        end
      else
        @charge_account = projects_charge_accounts(projects)
        @store = stores_dropdown
      end
      @json_data = { "charge_account" => @charge_account, "store" => @store,
                     "charge_account_id" => charge_account_id, "store_id" => store_id }
      render json: @json_data
    end

    # Update work order, charge account and store text fields at view from project select
    def po_update_charge_account_from_project
      project = params[:order]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? work_orders_dropdown : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        @store = project_stores(@project)
      else
        @work_order = work_orders_dropdown
        @charge_account = projects_charge_accounts(projects)
        @store = stores_dropdown
      end
      @json_data = { "work_order" => @work_order, "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Format numbers properly
    def po_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end
    def po_format_number_4
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def po_current_stock
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
    def po_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.expenditures
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : payment_payment_methods(@organization.id)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @suppliers = suppliers_dropdown
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
      @json_data = { "supplier" => @suppliers, "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown }
      render json: @json_data
    end

    # Update order number at view (generate_code_btn)
    def po_generate_no
      project = params[:project]

      # Builds no, if possible
      code = project == '$' ? '$err' : po_next_no(project)
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Product stock by store
    def po_product_stock
      product = params[:product]
      qty = params[:qty].to_f / 10000
      store = params[:store]
      stocks = nil
      if product != '0' && store != 0
        stocks = Stock.find_by_product_and_not_store_and_positive(product, store)
      end
      render json: stocks, include: :store
    end

    # infoButton
    def po_product_all_stocks
      product = params[:product]
      stocks = nil
      if product != '0'
        stocks = Stock.find_by_product_all_stocks(product)
      end
      render json: stocks, include: :store
    end

    # Check stocks before approve
    def po_check_stock_before_approve
      _order = params[:order]
      _array = []
      order = PurchaseOrder.find(_order)
      if !order.nil?
        order.purchase_order_items.each do |i|
          stocks = Stock.find_by_product_all_stocks(i.product)
          if !stocks.blank?
            stocks.each do |s|
              _is_current_store = s.store == i.store ? "*" : ""
              _array = _array << [i.id, s.product.full_code, i.description, number_with_precision(i.product.stock.round(4), precision: 4),
                                  s.store.name, number_with_precision(s.current.round(4), precision: 4), _is_current_store]
            end
          end
        end
      end
      render json: _array
    end

    # Approve order
    def po_approve_order
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
          order.order_status_id = 2
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

    # Email Report (jQuery)
    def send_purchase_order_form
      # Search purchase order & items
      #@purchase_order = PurchaseOrder.find(params[:id])
      #@items = @purchase_order.purchase_order_items.order('id')

      #pdf = send_data render_to_string, filename: "#{title}_#{@purchase_order.full_no}.pdf", type: 'application/pdf'
      code = send_email(params[:id])
      message = code == '$err' ? t(:send_error) : t(:send_ok)
      @json_data = { "code" => code, "message" => message }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /purchase_orders
    # GET /purchase_orders.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      supplier = params[:Supplier]
      status = params[:Status]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @suppliers = suppliers_dropdown if @suppliers.nil?
      @statuses = OrderStatus.order('id') if @statuses.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = PurchaseOrder.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :order_no, no
          else
            with(:order_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !status.blank?
          with :order_status_id, status
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @purchase_orders = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @purchase_orders }
        format.js
      end
    end

    # GET /purchase_orders/1
    # GET /purchase_orders/1.json
    def show
      @breadcrumb = 'read'
      @purchase_order = PurchaseOrder.find(params[:id])
      @items = @purchase_order.purchase_order_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      # Approvers
      @is_approver = company_approver(@purchase_order, @purchase_order.project.company, current_user.id) ||
                     office_approver(@purchase_order, @purchase_order.project.office, current_user.id)
                     #(current_user.has_role? :Administrator)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @purchase_order }
      end
    end

    # GET /purchase_orders/new
    # GET /purchase_orders/new.json
    def new
      @breadcrumb = 'create'
      @purchase_order = PurchaseOrder.new
      @offers = offers_dropdown
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = projects_charge_accounts(@projects)
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
      #@purchase_order.purchase_order_items.build

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @purchase_order }
      end
    end

    # GET /purchase_orders/1/edit
    def edit
      @breadcrumb = 'update'
      @purchase_order = PurchaseOrder.find(params[:id])
      @offers = @purchase_order.supplier.blank? ? offers_dropdown : @purchase_order.supplier.offers.order(:supplier_id, :offer_no, :id)
      @projects = projects_dropdown_edit(@purchase_order.project)
      @work_orders = @purchase_order.project.blank? ? work_orders_dropdown : @purchase_order.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@purchase_order)
      @stores = work_order_store(@purchase_order)
      @suppliers = @purchase_order.organization.blank? ? suppliers_dropdown : @purchase_order.organization.suppliers(:supplier_code)
      @payment_methods = @purchase_order.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@purchase_order.organization_id)
      @products = @purchase_order.organization.blank? ? products_dropdown : @purchase_order.organization.products(:product_code)
      #@work_orders = @purchase_order.work_order.blank? ? WorkOrder.order(:order_no) : WorkOrder.where('id = ?', @purchase_order.work_order)
      #@projects = @purchase_order.project.blank? ? Project.order(:project_code) : Project.where('id = ?', @purchase_order.project)
      #@charge_accounts = @purchase_order.charge_account.blank? ? ChargeAccount.order(:account_code) : ChargeAccount.where('id = ?', @purchase_order.charge_account)
      #@stores = @purchase_order.store.blank? ? Store.order(:name) : Store.where('id = ?', @purchase_order.store)
      #@items = @purchase_order.purchase_order_items.order('id')
    end

    # POST /purchase_orders
    # POST /purchase_orders.json
    def create
      @breadcrumb = 'create'
      @purchase_order = PurchaseOrder.new(params[:purchase_order])
      @purchase_order.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @purchase_order.save
          format.html { redirect_to @purchase_order, notice: crud_notice('created', @purchase_order) }
          format.json { render json: @purchase_order, status: :created, location: @purchase_order }
        else
          @offers = offers_dropdown
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = projects_charge_accounts(@projects)
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /purchase_orders/1
    # PUT /purchase_orders/1.json
    def update
      @breadcrumb = 'update'
      @purchase_order = PurchaseOrder.find(params[:id])

      items_changed = false
      if params[:purchase_order][:purchase_order_items_attributes]
        params[:purchase_order][:purchase_order_items_attributes].values.each do |new_item|
          current_item = PurchaseOrderItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.description != new_item[:description]) ||
              (current_item.code != new_item[:code]) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f) ||
              (current_item.price.to_f != new_item[:price].to_f) ||
              (current_item.discount_pct.to_f != new_item[:discount_pct].to_f) ||
              (current_item.discount.to_f != new_item[:discount].to_f) ||
              (current_item.tax_type_id.to_i != new_item[:tax_type_id].to_i) ||
              (current_item.delivery_date != new_item[:delivery_date].to_date) ||
              (current_item.project_id.to_i != new_item[:project_id].to_i) ||
              (current_item.work_order_id.to_i != new_item[:work_order_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.store_id.to_i != new_item[:store_id].to_i)))
            items_changed = true
            break
          end
        end
      end
      master_changed = false
      if ((params[:purchase_order][:organization_id].to_i != @purchase_order.organization_id.to_i) ||
          (params[:purchase_order][:project_id].to_i != @purchase_order.project_id.to_i) ||
          (params[:purchase_order][:order_no].to_s != @purchase_order.order_no) ||
          (params[:purchase_order][:order_date].to_date != @purchase_order.order_date) ||
          (params[:purchase_order][:supplier_id].to_i != @purchase_order.supplier_id.to_i) ||
          (params[:purchase_order][:offer_id].to_i != @purchase_order.offer_id.to_i) ||
          (params[:purchase_order][:order_status_id].to_i != @purchase_order.order_status_id.to_i) ||
          (params[:purchase_order][:work_order_id].to_i != @purchase_order.work_order_id.to_i) ||
          (params[:purchase_order][:charge_account_id].to_i != @purchase_order.charge_account_id.to_i) ||
          (params[:purchase_order][:store_id].to_i != @purchase_order.store_id.to_i) ||
          (params[:purchase_order][:payment_method_id].to_i != @purchase_order.payment_method_id.to_i) ||
          (params[:purchase_order][:retention_pct].to_f != @purchase_order.retention_pct.to_f) ||
          (params[:purchase_order][:retention_time].to_i != @purchase_order.retention_time.to_i) ||
          (params[:purchase_order][:discount_pct].to_f != @purchase_order.discount_pct.to_f) ||
          (params[:purchase_order][:store_address_1].to_s != @purchase_order.store_address_1) ||
          (params[:purchase_order][:store_address_2].to_s != @purchase_order.store_address_2) ||
          (params[:purchase_order][:store_phones].to_s != @purchase_order.store_phones) ||
          (params[:purchase_order][:remarks].to_s != @purchase_order.remarks))
        master_changed = true
      end

      respond_to do |format|
        if master_changed || items_changed
          @purchase_order.updated_by = current_user.id if !current_user.nil?
          if @purchase_order.update_attributes(params[:purchase_order])
            format.html { redirect_to @purchase_order,
                          notice: (crud_notice('updated', @purchase_order) + "#{undo_link(@purchase_order)}").html_safe }
            format.json { head :no_content }
          else
            @offers = @purchase_order.supplier.blank? ? offers_dropdown : @purchase_order.supplier.offers.order(:supplier_id, :offer_no, :id)
            @projects = projects_dropdown_edit(@purchase_order.project)
            @work_orders = @purchase_order.project.blank? ? work_orders_dropdown : @purchase_order.project.work_orders.order(:order_no)
            @charge_accounts = work_order_charge_account(@purchase_order)
            @stores = work_order_store(@purchase_order)
            @suppliers = @purchase_order.organization.blank? ? suppliers_dropdown : @purchase_order.organization.suppliers(:supplier_code)
            @payment_methods = @purchase_order.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@purchase_order.organization_id)
            @products = @purchase_order.organization.blank? ? products_dropdown : @purchase_order.organization.products(:product_code)
            format.html { render action: "edit" }
            format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @purchase_order }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /purchase_orders/1
    # DELETE /purchase_orders/1.json
    def destroy
      @purchase_order = PurchaseOrder.find(params[:id])

      respond_to do |format|
        if @purchase_order.destroy
          format.html { redirect_to purchase_orders_url,
                      notice: (crud_notice('destroyed', @purchase_order) + "#{undo_link(@purchase_order)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to purchase_orders_url, alert: "#{@purchase_order.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
        end
      end
    end

    # Report
    def purchase_order_form
      # Search purchase order & items
      @purchase_order = PurchaseOrder.find(params[:id])
      @items = @purchase_order.purchase_order_items.order('id')

      title = t("activerecord.models.purchase_order.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@purchase_order.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end

      # Updates status
      if @purchase_order.order_status_id < 3
        @purchase_order.order_status_id = 3
        @purchase_order.save
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Order is approved
    def cannot_edit(_order)
      !session[:is_administrator] && !_order.approver_id.blank?
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      PurchaseOrder.where('order_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.order_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    # Stores belonging to selected project
    def project_stores(_project)
      _array = []
      _stores = nil

      # Adding stores belonging to current project only
      # Stores with exclusive office
      if !_project.company.blank? && !_project.office.blank?
        _stores = Store.where("(company_id = ? AND office_id = ?)", _project.company.id, _project.office.id)
      elsif !_project.company.blank? && _project.office.blank?
        _stores = Store.where("(company_id = ?)", _project.company.id)
      elsif _project.company.blank? && !_project.office.blank?
        _stores = Store.where("(office_id = ?)", _project.office.id)
      else
        _stores = nil
      end
      ret_array(_array, _stores, 'id')
      # Stores with multiple offices
      if !_project.office.blank?
        _stores = StoreOffice.where("office_id = ?", _project.office.id)
        ret_array(_array, _stores, 'store_id')
      end

      # Returning founded stores
      _stores = Store.where(id: _array).order(:name)
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _projects.each do |i|
        _ret = ChargeAccount.expenditures.where(project_id: i.id)
        ret_array(_array, _ret, 'id')
      end

      # Adding global charge accounts belonging to projects organizations
      _sort_projects_by_organization = _projects.sort { |a,b| a.organization_id <=> b.organization_id }
      _previous_organization = _sort_projects_by_organization.first.organization_id
      _sort_projects_by_organization.each do |i|
        if _previous_organization != i.organization_id
          # when organization changes, process previous
          _ret = ChargeAccount.expenditures.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
          ret_array(_array, _ret, 'id')
          _previous_organization = i.organization_id
        end
      end
      # last organization, process previous
      _ret = ChargeAccount.expenditures.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
      ret_array(_array, _ret, 'id')

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
    end

    def work_order_charge_account(_order)
      if _order.work_order.blank? || _order.work_order.charge_account.blank?
        _charge_account = _order.project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(_order.project)
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

    def offers_dropdown
      _offers = session[:organization] != '0' ? Offer.where(organization_id: session[:organization].to_i).order(:supplier_id, :offer_no, :id) : Offer.order(:supplier_id, :offer_no, :id)
    end

    def charge_accounts_dropdown
      #_accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
      session[:organization] != '0' ? ChargeAccount.expenditures.where(organization_id: session[:organization].to_i) : ChargeAccount.expenditures
    end

    def charge_accounts_dropdown_edit(_project)
      #_accounts = ChargeAccount..where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
      ChargeAccount.expenditures.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
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

    def offers_array(_offers)
      _array = []
      _offers.each do |i|
        _array = _array << [i.id, i.offer_no, formatted_date(i.offer_date), i.supplier.full_name]
      end
      _array
    end

    def products_array(_products)
      _array = []
      _products.each do |i|
        _array = _array << [i.id, i.full_code, i.main_description[0,40]]
      end
      _array
    end

    # Returns _array from _ret table/model filled with _id attribute
    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
      end
    end

    # Use purchase price, if any. Otherwise, the reference price
    # _product is the instance variable @product
    # _supplier is a variable containing supplier_id
    def product_price_to_apply(_product, _supplier)
      _price = 0
      _discount_rate = 0
      _code = ""
      _purchase_price = PurchasePrice.find_by_product_and_supplier(_product.id, _supplier)
      if !_purchase_price.nil?
        _price = _purchase_price.price
        _discount_rate = _purchase_price.discount_rate
        _code = _purchase_price.code
      else
        _price = _product.reference_price
        _discount_rate = Supplier.find(_supplier).discount_rate rescue 0
      end
      return _price, _discount_rate, _code
    end

    def send_email(_purchase_order)
      code = '$ok'
      from = nil
      to = nil

      # Search purchase order & items
      @purchase_order = PurchaseOrder.find(_purchase_order)
      @items = @purchase_order.purchase_order_items.order(:id)

      title = t("activerecord.models.purchase_order.one") + "_" + @purchase_order.full_no + ".pdf"
      #pdf = render_to_string(filename: "#{title}_#{@purchase_order.full_no}.pdf", type: 'application/pdf')
      pdf = render_to_string(filename: "#{title}", type: 'application/pdf')
      from = !current_user.nil? ? User.find(current_user.id).email : User.find(@purchase_order.created_by).email
      to = !@purchase_order.supplier.email.blank? ? @purchase_order.supplier.email : nil

      if from.blank? || to.blank?
        code = "$err"
      else
        # Send e-mail
        Notifier.send_purchase_order(@purchase_order, from, to, title, pdf).deliver
      end

      code
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
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
    end
  end
end
