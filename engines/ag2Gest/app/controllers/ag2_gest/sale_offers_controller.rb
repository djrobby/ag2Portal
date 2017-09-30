require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SaleOffersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:so_remove_filters,
                                               :so_restore_filters,
                                               :so_generate_no,
                                               :so_update_selects_from_organization,
                                               :so_update_product_select_from_organization,
                                               :so_update_selects_from_project,
                                               :so_update_request_select_from_client,
                                               :so_update_selects_from_order,
                                               :so_format_number,
                                               :so_format_number_4,
                                               :so_item_totals,
                                               :so_update_description_prices_from_product,
                                               :so_update_amount_from_price_or_quantity,
                                               :so_update_approval_date,
                                               :send_sale_offer_form,
                                               :sale_offer_form]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit
    # => returns client code & full name
    helper_method :client_name
    # => index filters
    helper_method :so_remove_filters, :so_restore_filters

    # Update invoice number at view (generate_code_btn)
    def so_generate_no
      project = params[:project]

      # Builds no, if possible
      code = project == '$' ? '$err' : sale_offer_next_no(project)
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update selects at view from organization
    def so_update_selects_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @clients = @organization.blank? ? clients_dropdown : @organization.clients.order(:client_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.expenditures
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : collection_payment_methods(@organization.id)
        @contracting_requests = @organization.blank? ? contracting_requests_dropdown : projects_contracting_requests(@projects)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @clients = clients_dropdown
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @contracting_requests = contracting_requests_dropdown
        @products = products_dropdown
      end
      # Work orders array
      @orders_dropdown = orders_array(@work_orders)
      # Products array
      @products_dropdown = products_array(@products)
      # Clients array
      @clients_dropdown = clients_array(@clients)
      # Contracting requests array
      @constracting_requests_dropdown = contracting_requests_array(@contracting_requests)
      # Setup JSON
      @json_data = { "client" => @clients_dropdown, "project" => @projects, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "contracting_request" => @constracting_requests_dropdown,
                     "product" => @products_dropdown }
      render json: @json_data
    end

    # Update product select at view from organization select
    def so_update_product_select_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @products = products_dropdown
      end
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "product" => @products_dropdown }
      render json: @json_data
    end

    # Update selects at view from organization
    def so_update_selects_from_project
      project = params[:project]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @contracting_requests = @project.blank? ? projects_contracting_requests(projects) : projects_contracting_requests(@project)
        @work_order = @project.blank? ? work_orders_dropdown : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        @store = project_stores(@project)
      else
        @contracting_requests = projects_contracting_requests(projects)
        @work_order = work_orders_dropdown
        @charge_account = projects_charge_accounts(projects)
        @store = stores_dropdown
      end
      # Work orders array
      @orders_dropdown = orders_array(@work_order)
      # Contracting requests array
      @constracting_requests_dropdown = contracting_requests_array(@contracting_requests)
      # Setup JSON
      @json_data = { "contracting_request" => @constracting_requests_dropdown, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Update contracting request select at view from client
    def so_update_request_select_from_client
      client = params[:client]
      project = params[:project]
      projects = projects_dropdown
      if client != '0' && project != 0
        @client = Client.find(client)
        @project = Project.find(project)
        if @project.blank?
          @contracting_requests = @client.blank? ? projects_contracting_requests(projects) : @client.connection_requests.by_no
        else
          @contracting_requests = @client.blank? ? projects_contracting_requests(@project) : @client.connection_requests.belongs_to_project(@project)
        end
      elsif client != 0
        @client = Client.find(client)
        @contracting_requests = @client.blank? ? projects_contracting_requests(projects) : @client.connection_requests.by_no
      else
        @contracting_requests = projects_contracting_requests(projects)
      end
      # Contracting requests array
      @constracting_requests_dropdown = contracting_requests_array(@contracting_requests)
      # Setup JSON
      @json_data = { "contracting_request" => @constracting_requests_dropdown }
      render json: @json_data
    end

    # Update charge account and store text fields at view from work order select
    def so_update_selects_from_order
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

    # Format numbers properly
    def ci_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end
    def ci_format_number_4
      num = params[:num].to_f / 10000
      num = number_with_precision(num.round(4), precision: 4)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Calculate and format item totals properly
    def so_item_totals
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

    # Update description and prices text fields at view from product select
    def so_update_description_prices_from_product
      product = params[:product]
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
      if product != '0'
        @product = Product.find(product)
        # Assignment
        description = @product.main_description[0,40]
        qty = params[:qty].to_f / 10000
        price = @product.sell_price
        code = @product.product_code
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
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id,
                     "discountp" => discount_p, "discount" => discount, "code" => code, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def so_update_amount_from_price_or_quantity
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
      render json: @json_data
    end

    def so_update_approval_date
      @json_data = { "approval_date" => formatted_timestamp(Time.now.utc.getlocal) }
      render json: @json_data
    end

    #
    # Emission Methods
    #
    # Email Report (jQuery)
    def send_sale_offer_form
      code = send_email(params[:id])
      message = code == '$err' ? t(:send_error) : t(:send_ok)
      @json_data = { "code" => code, "message" => message }
      render json: @json_data
    end

    # Report form
    def sale_offer_form
      # Search offer & items
      @sale_offer = SaleOffer.find(params[:id])
      @items = @sale_offer.sale_offer_items.order('id')

      title = t("activerecord.models.sale_offer.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@sale_offer.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    #
    # Default Methods
    #
    # GET /sale_offers
    # GET /sale_offers.json
    def index
      manage_filter_state
      no = params[:No]
      client = params[:Client]
      project = params[:Project]
      status = params[:Status]
      order = params[:Order]
      request = params[:Request]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @client = !client.blank? ? Client.find(client).to_label : " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @work_order = !order.blank? ? WorkOrder.find(order).full_name : " "
      @contracting_request = !request.blank? ? ContractingRequest.find(request).full_no_and_client : " "
      @status = sale_offer_statuses_dropdown if @status.nil?

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = SaleOffer.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :offer_no, no
          else
            with(:offer_no).starting_with(no)
          end
        end
        if !client.blank?
          with :client_id, client
        end
        if !project.blank?
          with :project_id, project
        end
        if !status.blank?
          with :sale_offer_status_id, status
        end
        if !order.blank?
          with :work_order_id, order
        end
        if !request.blank?
          with :contracting_request_id, request
        end
        data_accessor_for(SaleOffer).include = [:client, :contracting_request]
        order_by :sort_no, :desc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @sale_offers = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sale_offers }
        format.js
      end
    end

    # GET /sale_offers/1
    # GET /sale_offers/1.json
    def show
      @breadcrumb = 'read'
      @sale_offer = SaleOffer.find(params[:id])
      @items = @sale_offer.sale_offer_items.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sale_offer }
      end
    end

    # GET /sale_offers/new
    # GET /sale_offers/new.json
    def new
      @breadcrumb = 'create'
      @sale_offer = SaleOffer.new
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = projects_charge_accounts(@projects)
      @stores = stores_dropdown
      @clients = clients_dropdown
      @payment_methods = payment_methods_dropdown
      @status = sale_offer_statuses_dropdown
      # @products = products_dropdown
      @contracting_requests = contracting_requests_dropdown
      @approval = 'false'

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer }
      end
    end

    # GET /sale_offers/1/edit
    def edit
      @breadcrumb = 'update'
      @sale_offer = SaleOffer.find(params[:id])
      @projects = projects_dropdown_edit(@sale_offer.project)
      @work_orders = @sale_offer.project.blank? ? work_orders_dropdown : @sale_offer.project.work_orders.by_no
      @charge_accounts = work_order_charge_account(@sale_offer, @projects)
      @stores = work_order_store(@sale_offer)
      @clients = @sale_offer.organization.blank? ? clients_dropdown : @sale_offer.organization.clients.by_code
      @payment_methods = @sale_offer.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@sale_offer.organization_id)
      @status = sale_offer_statuses_dropdown
      # @products = @sale_offer.organization.blank? ? products_dropdown : @sale_offer.organization.products.by_code
      if @sale_offer.project.blank?
        @contracting_requests = @sale_offer.client.blank? ? projects_contracting_requests(@projects) : @sale_offer.client.connection_requests.by_no
      else
        @contracting_requests = @sale_offer.client.blank? ? projects_contracting_requests(@sale_offer.project) : @sale_offer.client.connection_requests.belongs_to_project(@sale_offer.project)
      end
      @approval = @sale_offer.sale_offer_status_id == SaleOfferStatus::APPROVED ? 'true' : 'false'
    end

    # POST /sale_offers
    # POST /sale_offers.json
    def create
      @breadcrumb = 'create'
      @sale_offer = SaleOffer.new(params[:sale_offer])
      @sale_offer.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @sale_offer.save
          format.html { redirect_to @sale_offer, notice: crud_notice('created', @sale_offer) }
          format.json { render json: @sale_offer, status: :created, location: @sale_offer }
        else
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = projects_charge_accounts(@projects)
          @stores = stores_dropdown
          @clients = clients_dropdown
          @payment_methods = payment_methods_dropdown
          @status = sale_offer_statuses_dropdown
          # @products = products_dropdown
          @contracting_requests = contracting_requests_dropdown
          @approval = 'false'
          format.html { render action: "new" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /sale_offers/1
    # PUT /sale_offers/1.json
    def update
      @breadcrumb = 'update'
      @sale_offer = SaleOffer.find(params[:id])

      items_changed = false
      if params[:sale_offer][:sale_offer_items_attributes]
        params[:sale_offer][:sale_offer_items_attributes].values.each do |new_item|
          current_item = SaleOfferItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.description != new_item[:description]) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f) ||
              (current_item.price.to_f != new_item[:price].to_f) ||
              (current_item.discount_pct.to_f != new_item[:discount_pct].to_f) ||
              (current_item.discount.to_f != new_item[:discount].to_f) ||
              (current_item.tax_type_id.to_i != new_item[:tax_type_id].to_i) ||
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
      if ((params[:sale_offer][:organization_id].to_i != @sale_offer.organization_id.to_i) ||
          (params[:sale_offer][:offer_no].to_s != @sale_offer.offer_no) ||
          (params[:sale_offer][:offer_date].to_date != @sale_offer.offer_date) ||
          (params[:sale_offer][:sale_offer_status_id].to_i != @sale_offer.sale_offer_status_id.to_i) ||
          (params[:sale_offer][:client_id].to_i != @sale_offer.client_id.to_i) ||
          (params[:sale_offer][:contracting_request_id].to_i != @sale_offer.contracting_request_id.to_i) ||
          (params[:sale_offer][:payment_method_id].to_i != @sale_offer.payment_method_id.to_i) ||
          (params[:sale_offer][:work_order_id].to_i != @sale_offer.work_order_id.to_i) ||
          (params[:sale_offer][:charge_account_id].to_i != @sale_offer.charge_account_id.to_i) ||
          (params[:sale_offer][:store_id].to_i != @sale_offer.store_id.to_i) ||
          (params[:sale_offer][:discount_pct].to_f != @sale_offer.discount_pct.to_f) ||
          (params[:sale_offer][:approval_date].to_date != @sale_offer.approval_date) ||
          (params[:sale_offer][:approver].to_s != @sale_offer.approver) ||
          (params[:sale_offer][:remarks].to_s != @sale_offer.remarks))
        master_changed = true
      end

      respond_to do |format|
        if master_changed || items_changed
          @sale_offer.updated_by = current_user.id if !current_user.nil?
          if @sale_offer.update_attributes(params[:sale_offer])
            format.html { redirect_to @sale_offer,
                          notice: (crud_notice('updated', @sale_offer) + "#{undo_link(@sale_offer)}").html_safe }
            format.json { head :no_content }
          else
            @projects = projects_dropdown_edit(@sale_offer.project)
            @work_orders = @sale_offer.project.blank? ? work_orders_dropdown : @sale_offer.project.work_orders.by_no
            @charge_accounts = work_order_charge_account(@sale_offer, @projects)
            @stores = work_order_store(@sale_offer)
            @clients = @sale_offer.organization.blank? ? clients_dropdown : @sale_offer.organization.clients.by_code
            @payment_methods = @sale_offer.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@sale_offer.organization_id)
            @status = sale_offer_statuses_dropdown
            # @products = @sale_offer.organization.blank? ? products_dropdown : @sale_offer.organization.products.by_code
            if @sale_offer.project.blank?
              @contracting_requests = @sale_offer.client.blank? ? projects_contracting_requests(@projects) : @sale_offer.client.connection_requests.by_no
            else
              @contracting_requests = @sale_offer.client.blank? ? projects_contracting_requests(@sale_offer.project) : @sale_offer.client.connection_requests.belongs_to_project(@sale_offer.project)
            end
            @approval = @sale_offer.sale_offer_status_id == SaleOfferStatus::APPROVED ? 'true' : 'false'
            format.html { render action: "edit" }
            format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @sale_offer }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /sale_offers/1
    # DELETE /sale_offers/1.json
    def destroy
      @sale_offer = SaleOffer.find(params[:id])

      respond_to do |format|
        if @sale_offer.destroy
          format.html { redirect_to sale_offers_url,
                      notice: (crud_notice('destroyed', @sale_offer) + "#{undo_link(@sale_offer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to sale_offers_url, alert: "#{@sale_offer.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Offer is totally billed
    def cannot_edit(_offer)
      !session[:is_administrator] && _offer.unbilled_balance <= 0
    end

    def client_name(_offer)
      _name = _offer.client.full_name_or_company_and_code rescue nil
      _name.blank? ? '' : _name[0,40]
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
      SaleOffer.where('offer_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.offer_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def projects_dropdown
      _array = []
      _projects = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
        else
          _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
        else
          _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
        end
      end

      # Returning founded projects
      ret_array(_array, _projects, 'id')
      _projects = Project.where(id: _array).by_code
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _ret = ChargeAccount.incomes.where(project_id: _projects)
      ret_array(_array, _ret, 'id')

      # Adding global charge accounts belonging to projects organizations
      _sort_projects_by_organization = _projects.sort { |a,b| a.organization_id <=> b.organization_id }
      _previous_organization = _sort_projects_by_organization.first.organization_id
      _sort_projects_by_organization.each do |i|
        if _previous_organization != i.organization_id
          # when organization changes, process previous
          _ret = ChargeAccount.incomes.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
          ret_array(_array, _ret, 'id')
          _previous_organization = i.organization_id
        end
      end
      # last organization, process previous
      _ret = ChargeAccount.incomes.where('(project_id IS NULL AND charge_accounts.organization_id = ?)', _previous_organization)
      ret_array(_array, _ret, 'id')

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
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

    def work_order_charge_account(_offer, _projects)
      if _offer.work_order.blank? || _offer.work_order.charge_account.blank?
        _charge_account = _offer.project.blank? ? projects_charge_accounts(_projects) : charge_accounts_dropdown_edit(_offer.project)
      else
        _charge_account = ChargeAccount.where("id = ?", _offer.work_order.charge_account)
      end
      _charge_account
    end

    def work_order_store(_offer)
      if _offer.work_order.blank? || _offer.work_order.store.blank?
        _store = _offer.project.blank? ? stores_dropdown : project_stores(_offer.project)
      else
        _store = Store.where("id = ?", _offer.work_order.store)
      end
      _store
    end

    # Contracting requests belonging to projects
    def projects_contracting_requests(_projects)
      ContractingRequest.is_connection_belongs_to_project(_projects)
    end

    def sale_offer_statuses_dropdown
      SaleOfferStatus.all
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.incomes.where(organization_id: session[:organization].to_i) : ChargeAccount.incomes
    end

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.incomes.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def contracting_requests_dropdown
      session[:organization] != '0' ? ContractingRequest.is_connection_belongs_to_organization(session[:organization].to_i) : ContractingRequest.is_connection
    end

    def clients_dropdown
      session[:organization] != '0' ? Client.belongs_to_organization(session[:organization].to_i) : Client.by_code
    end

    def payment_methods_dropdown
      session[:organization] != '0' ? collection_payment_methods(session[:organization].to_i) : collection_payment_methods(0)
    end

    def collection_payment_methods(_organization)
      _organization != 0 ? PaymentMethod.collections_belong_to_organization(_organization) : PaymentMethod.collections
    end

    def products_dropdown
      session[:organization] != '0' ? Product.belongs_to_organization(session[:organization].to_i) : Product.by_code
    end

    def products_array(_products)
      _array = []
      _products.each do |i|
        _array = _array << [i.id, i.full_code, i.main_description[0,40]]
      end
      _array
    end

    def orders_array(_orders)
      _array = []
      _orders.each do |i|
        _array = _array << [i.id, i.full_name]
      end
      _array
    end

    def clients_array(_clients)
      _array = []
      _clients.each do |i|
        _array = _array << [i.id, i.full_name_or_company_and_code]
      end
      _array
    end

    def contracting_requests_array(_requests)
      _array = []
      _requests.each do |i|
        _array = _array << [i.id, i.full_no_date_client]
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

    # Send email to client
    def send_email(_invoice)
      code = '$ok'
      from = nil
      to = nil

      # Search offer & items
      @sale_offer = SaleOffer.find(_invoice)
      @items = @sale_offer.sale_offer_items.order(:id)

      title = t("activerecord.models.sale_offer.one") + "_" + @sale_offer.full_no + ".pdf"
      pdf = render_to_string(filename: "#{title}", type: 'application/pdf')
      from = !current_user.nil? ? User.find(current_user.id).email : User.find(@sale_offer.created_by).email
      to = !@sale_offer.client.email.blank? ? @sale_offer.client.email : nil

      if from.blank? || to.blank?
        code = "$err"
      else
        # Send e-mail
        Notifier.send_sale_offer(@sale_offer, from, to, title, pdf).deliver
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
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
      # order
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
      # request
      if params[:Request]
        session[:Request] = params[:Request]
      elsif session[:Request]
        params[:Request] = session[:Request]
      end
    end

    def so_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Client] = ""
      params[:Project] = ""
      params[:Status] = ""
      params[:Order] = ""
      params[:Request] = ""
      return " "
    end

    def so_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Client] = session[:Client]
      params[:Project] = session[:Project]
      params[:Status] = session[:Status]
      params[:Order] = session[:Order]
      params[:Request] = session[:Request]
    end
  end
end
