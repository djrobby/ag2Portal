require_dependency "ag2_products/application_controller"

module Ag2Products
  class DeliveryNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:dn_totals,
                                               :dn_update_description_prices_from_product_store,
                                               :dn_update_description_prices_from_product,
                                               :dn_update_amount_and_costs_from_price_or_quantity,
                                               :dn_update_charge_account_from_order,
                                               :dn_update_charge_account_from_project,
                                               :dn_update_offer_select_from_client,
                                               :dn_format_number,
                                               :dn_current_stock,
                                               :dn_update_project_textfields_from_organization,
                                               :dn_generate_no]
    # Update sale offer select at view from client select
    def dn_update_offer_select_from_client
      client = params[:client]
      if client != '0'
        @client = Client.find(client)
        @offers = @client.blank? ? offers_dropdown : @client.sale_offers.order(:client_id, :offer_no, :id)
      else
        @offers = offers_dropdown
      end
      # Offers array
      @offers_dropdown = offers_array(@offers)
      # Setup JSON
      @json_data = { "offer" => @offers_dropdown }
      render json: @json_data
    end

    # Calculate and format totals properly
    def dn_totals
      qty = params[:qty].to_f / 10000
      amount = params[:amount].to_f / 10000
      costs = params[:costs].to_f / 10000
      tax = params[:tax].to_f / 10000
      discount_p = params[:discount_p].to_f / 100
      # Bonus
      discount = discount_p != 0 ? amount * (discount_p / 100) : 0
      # Taxable
      taxable = amount
      # Total
      total = taxable + tax      
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      discount = number_with_precision(discount.round(4), precision: 4)
      taxable = number_with_precision(taxable.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "costs" => costs.to_s, "amount" => amount.to_s, "tax" => tax.to_s,
                     "discount" => discount.to_s, "taxable" => taxable.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product & store selects
    def dn_update_description_prices_from_product_store
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

    # Update description and prices text fields at view from product select
    def dn_update_description_prices_from_product
      product = params[:product]
      description = ""
      qty = 0
      cost = 0
      costs = 0
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
        cost = @product.reference_price
        costs = qty * cost
        price = @product.sell_price
        amount = qty * price
        tax_type_id = @product.tax_type.id
        tax_type_tax = @product.tax_type.tax
        tax = amount * (tax_type_tax / 100)
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      costs = number_with_precision(costs.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "description" => description,
                     "cost" => cost.to_s, "costs" => costs.to_s,
                     "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id }
      render json: @json_data
    end

    # Update amount, costs and tax text fields at view (quantity or price changed)
    def dn_update_amount_and_costs_from_price_or_quantity
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

    # Update charge account and store text fields at view from work order select
    def dn_update_charge_account_from_order
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
    def dn_update_charge_account_from_project
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

    # Format numbers properly
    def dn_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def dn_current_stock
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
    def dn_update_project_textfields_from_organization
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

    # Update delivery number at view (generate_code_btn)
    def dn_generate_no
      organization = params[:org]

      # Builds no, if possible
      code = organization == '$' ? '$err' : dn_next_no(organization)
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    # GET /delivery_notes
    # GET /delivery_notes.json
    def index
      manage_filter_state
      no = params[:No]
      client = params[:Client]
      project = params[:Project]
      order = params[:Order]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @clients = clients_dropdown if @clients.nil?
      @projects = projects_dropdown if @projects.nil?
      @work_orders = work_orders_dropdown if @work_orders.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = DeliveryNote.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :delivery_no, no
          else
            with(:delivery_no).starting_with(no)
          end
        end
        if !client.blank?
          with :client_id, client
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @delivery_notes = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @delivery_notes }
        format.js
      end
    end
  
    # GET /delivery_notes/1
    # GET /delivery_notes/1.json
    def show
      @breadcrumb = 'read'
      @delivery_note = DeliveryNote.find(params[:id])
      @items = @delivery_note.delivery_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/new
    # GET /delivery_notes/new.json
    def new
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new
      @offers = offers_dropdown
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @clients = clients_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
      @offers = @delivery_note.client.blank? ? offers_dropdown : @delivery_note.client.sale_offers.order(:client_id, :offer_no, :id)
      @projects = projects_dropdown_edit(@delivery_note.project)
      @work_orders = @delivery_note.project.blank? ? work_orders_dropdown : @delivery_note.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@delivery_note)
      @stores = work_order_store(@delivery_note)
      @clients = @delivery_note.organization.blank? ? clients_dropdown : @delivery_note.organization.clients.order(:client_code)
      @payment_methods = @delivery_note.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@delivery_note.organization_id)
      @products = @delivery_note.organization.blank? ? products_dropdown : @delivery_note.organization.products.order(:product_code)
    end
  
    # POST /delivery_notes
    # POST /delivery_notes.json
    def create
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new(params[:delivery_note])
      @delivery_note.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.save
          format.html { redirect_to @delivery_note, notice: crud_notice('created', @delivery_note) }
          format.json { render json: @delivery_note, status: :created, location: @delivery_note }
        else
          @offers = offers_dropdown
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @clients = clients_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /delivery_notes/1
    # PUT /delivery_notes/1.json
    def update
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
      @delivery_note.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.update_attributes(params[:delivery_note])
          format.html { redirect_to @delivery_note,
                        notice: (crud_notice('updated', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          @offers = @delivery_note.client.blank? ? offers_dropdown : @delivery_note.client.sale_offers.order(:client_id, :offer_no, :id)
          @projects = projects_dropdown_edit(@purchase_order.project)
          @work_orders = @delivery_note.project.blank? ? work_orders_dropdown : @delivery_note.project.work_orders.order(:order_no)
          @charge_accounts = work_order_charge_account(@delivery_note)
          @stores = work_order_store(@delivery_note)
          @clients = @delivery_note.organization.blank? ? clients_dropdown : @delivery_note.organization.clients.order(:client_code)
          @payment_methods = @delivery_note.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@delivery_note.organization_id)
          @products = @delivery_note.organization.blank? ? products_dropdown : @delivery_note.organization.products.order(:product_code)
          format.html { render action: "edit" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /delivery_notes/1
    # DELETE /delivery_notes/1.json
    def destroy
      @delivery_note = DeliveryNote.find(params[:id])

      respond_to do |format|
        if @delivery_note.destroy
          format.html { redirect_to delivery_notes_url,
                      notice: (crud_notice('destroyed', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to delivery_notes_url, alert: "#{@delivery_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end

    # Delivery note form (report)
    def delivery_note_form
      # Search delivery note & items
      @delivery_note = DeliveryNote.find(params[:id])
      @items = @delivery_note.delivery_note_items

      title = t("activerecord.models.delivery_note.one")      

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@delivery_note.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Delivery note form with prices (report)
    def delivery_note_form_client
      # Search delivery note & items
      @delivery_note = DeliveryNote.find(params[:id])
      @items = @delivery_note.delivery_note_items

      title = t("activerecord.models.delivery_note.one")
      tail = t("activerecord.attributes.delivery_note.client") + ' ' + @delivery_note.client.full_code      

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@delivery_note.full_no}_#{tail}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
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

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      DeliveryNote.where('delivery_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.delivery_no
      end
      _numbers = _numbers.blank? ? no : _numbers
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

    def clients_dropdown
      _clients = session[:organization] != '0' ? Client.where(organization_id: session[:organization].to_i).order(:client_code) : Client.order(:client_code)
    end

    def offers_dropdown
      _offers = session[:organization] != '0' ? SaleOffer.where(organization_id: session[:organization].to_i).order(:client_id, :offer_no, :id) : SaleOffer.order(:client_id, :offer_no, :id)
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
      _methods = session[:organization] != '0' ? collection_payment_methods(session[:organization].to_i) : collection_payment_methods(0)
    end
    
    def collection_payment_methods(_organization)
      if _organization != 0
        _methods = PaymentMethod.where("(flow = 3 OR flow = 1) AND organization_id = ?", _organization).order(:description)
      else
        _methods = PaymentMethod.where("flow = 3 OR flow = 1").order(:description)
      end
      _methods
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end    
    
    def offers_array(_offers)
      _array = []
      _offers.each do |i|
        _array = _array << [i.id, i.full_no, formatted_date(i.offer_date), i.client.full_name] 
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
      # client
      if params[:Client]
        session[:Client] = params[:Client]
      elsif session[:Client]
        params[:Client] = session[:Client]
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
