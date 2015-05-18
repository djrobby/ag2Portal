require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OfferRequestsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:or_update_description_prices_from_product_store,
                                               :or_update_description_prices_from_product,
                                               :or_update_charge_account_from_order,
                                               :or_update_charge_account_from_project,
                                               :or_update_amount_from_price_or_quantity,
                                               :or_format_numbers,
                                               :or_totals,
                                               :or_current_stock,
                                               :or_update_project_textfields_from_organization,
                                               :or_generate_no,
                                               :or_approve_offer,
                                               :or_disapprove_offer]
    # Calculate and format totals properly
    def or_totals
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
    def or_update_description_prices_from_product_store
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
    def or_update_description_prices_from_product
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
    def or_update_amount_from_price_or_quantity
      price = params[:price].to_f / 10000
      qty = params[:qty].to_f / 10000
      tax_type = params[:tax_type].to_i
      #discount_p = params[:discount_p].to_f / 100
      #discount = params[:discount].to_f / 10000
      product = params[:product]
      if tax_type.blank? || tax_type == "0"
        if !product.blank? && product != "0"
          tax_type = Product.find(product).tax_type.id
        else
          tax_type = TaxType.where('expiration IS NULL').order('id').first.id
        end
      end
      tax = TaxType.find(tax_type).tax
      #if discount_p > 0
      #  discount = price * (discount_p / 100)
      #end
      #amount = qty * (price - discount)
      amount = qty * price
      tax = amount * (tax / 100)
      qty = number_with_precision(qty.round(4), precision: 4)
      price = number_with_precision(price.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      #discount_p = number_with_precision(discount_p.round(2), precision: 2)
      #discount = number_with_precision(discount.round(4), precision: 4)
      @json_data = { "quantity" => qty.to_s, "price" => price.to_s, "amount" => amount.to_s, "tax" => tax.to_s }
      #               "discountp" => discount_p.to_s, "discount" => discount.to_s }

      respond_to do |format|
        format.html # or_update_amount_from_price_or_quantity.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update charge account and store text fields at view from work order select
    def or_update_charge_account_from_order
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
    def or_update_charge_account_from_project
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
    def or_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def or_current_stock
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
    def or_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
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
      @json_data = { "supplier" => @suppliers, "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products }
      render json: @json_data
    end

    # Update order number at view (generate_code_btn)
    def or_generate_no
      project = params[:project]

      # Builds no, if possible
      code = project == '$' ? '$err' : or_next_no(project)
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Approve offer
    def or_approve_offer
      _offer = params[:offer]
      _offer_request = params[:offer_request]
      code = '$err'
      _approver_id = nil
      _approver = nil
      _approval_date = nil

      offer_request = OfferRequest.find(_offer_request)
      if !offer_request.nil?
        if offer_request.approved_offer_id.blank?
          # Can approve offer
          offer = Offer.find(_offer)
          if !offer.nil? && !current_user.nil?
            # Attempt approve
            _approver_id = current_user.id
            _approval_date = DateTime.now
            offer.approver_id = _approver_id
            offer.approval_date = _approval_date
            if offer.save
              offer_request.approved_offer_id = _offer
              offer_request.approver_id = _approver_id
              offer_request.approval_date = _approval_date
              if offer_request.save
                # Success
                code = '$ok'
              else
                # Can't save offer request
                code = '$write'
              end
            else
              # Can't save offer
              code = '$write'
            end
          else
            # Offer not found or user not logged in
            code = '$err'
          end
        else
          # There is an offer already approved
          code = '$warn'
        end
      else
        # Offer request not found
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

    # Disapprove offer
    def or_disapprove_offer
      _offer = params[:offer]
      _offer_request = params[:offer_request]
      code = '$err'

      offer_request = OfferRequest.find(_offer_request)
      if !offer_request.nil?
        if !offer_request.approved_offer_id.blank?
          # Can disapprove offer
          offer = Offer.find(_offer)
          if !offer.nil?
            # Attempt disapprove
            offer.approver_id = nil
            offer.approval_date = nil
            if offer.save
              offer_request.approved_offer_id = nil
              offer_request.approver_id = nil
              offer_request.approval_date = nil
              if offer_request.save
                # Success
                code = '$ok'
              else
                # Can't save offer request
                code = '$write'
              end
            else
              # Can't save offer
              code = '$write'
            end
          else
            # Offer not found
            code = '$err'
          end
        else
          # There isn't previous offer approved
          code = '$warn'
        end
      else
        # Offer request not found
        code = '$err'
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /offer_requests
    # GET /offer_requests.json
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

      if !supplier.blank?
        @request_suppliers = OfferRequestSupplier.group(:offer_request_id).where(supplier_id: supplier)
      else
        @request_suppliers = OfferRequestSupplier.group(:offer_request_id)
      end

      current_suppliers = @request_suppliers.blank? ? [0] : current_suppliers_for_index(@request_suppliers)
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      
      @search = OfferRequest.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          with :request_no, no
        end
        if !supplier.blank?
          with :id, current_suppliers
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :request_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @offer_requests = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offer_requests }
        format.js
      end
    end
  
    # GET /offer_requests/1
    # GET /offer_requests/1.json
    def show
      @breadcrumb = 'read'
      @offer_request = OfferRequest.find(params[:id])
      @items = @offer_request.offer_request_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @suppliers = @offer_request.offer_request_suppliers.paginate(:page => params[:page], :per_page => per_page).order('id')
      @offers = @offer_request.offers.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/new
    # GET /offer_requests/new.json
    def new
      @breadcrumb = 'create'
      @offer_request = OfferRequest.new
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/1/edit
    def edit
      @breadcrumb = 'update'
      @offer_request = OfferRequest.find(params[:id])
      @projects = projects_dropdown_edit(@offer_request.project)
      @work_orders = @offer_request.project.blank? ? work_orders_dropdown : @offer_request.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@offer_request)
      @stores = work_order_store(@offer_request)
      @suppliers = @offer_request.organization.blank? ? suppliers_dropdown : @offer_request.organization.suppliers(:supplier_code)
      @payment_methods = @offer_request.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@offer_request.organization_id)
      @products = @offer_request.organization.blank? ? products_dropdown : @offer_request.organization.products(:product_code)
    end
  
    # POST /offer_requests
    # POST /offer_requests.json
    def create
      @breadcrumb = 'create'
      @offer_request = OfferRequest.new(params[:offer_request])
      @offer_request.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer_request.save
          format.html { redirect_to @offer_request, notice: crud_notice('created', @offer_request) }
          format.json { render json: @offer_request, status: :created, location: @offer_request }
        else
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /offer_requests/1
    # PUT /offer_requests/1.json
    def update
      @breadcrumb = 'update'
      @offer_request = OfferRequest.find(params[:id])
      @offer_request.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer_request.update_attributes(params[:offer_request])
          format.html { redirect_to @offer_request,
                        notice: (crud_notice('updated', @offer_request) + "#{undo_link(@offer_request)}").html_safe }
          format.json { head :no_content }
        else
          @projects = projects_dropdown_edit(@offer_request.project)
          @work_orders = @offer_request.project.blank? ? work_orders_dropdown : @offer_request.project.work_orders.order(:order_no)
          @charge_accounts = work_order_charge_account(@offer_request)
          @stores = work_order_store(@offer_request)
          @suppliers = @offer_request.organization.blank? ? suppliers_dropdown : @offer_request.organization.suppliers(:supplier_code)
          @payment_methods = @offer_request.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@offer_request.organization_id)
          @products = @offer_request.organization.blank? ? products_dropdown : @offer_request.organization.products(:product_code)
          format.html { render action: "edit" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /offer_requests/1
    # DELETE /offer_requests/1.json
    def destroy
      @offer_request = OfferRequest.find(params[:id])

      respond_to do |format|
        if @offer_request.destroy
          format.html { redirect_to offer_requests_url,
                      notice: (crud_notice('destroyed', @offer_request) + "#{undo_link(@offer_request)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to offer_requests_url, alert: "#{@offer_request.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end

    # Report
    def offer_request_form
      # Search offer request & items
      @offer_request = OfferRequest.find(params[:id])
      @items = @offer_request.offer_request_items.order('id')
      @suppliers = @offer_request.offer_request_suppliers.order('id')

      title = t("activerecord.models.offer_request.one")      

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@offer_request.full_no}.pdf",
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
    
    def current_suppliers_for_index(_suppliers)
      _current_suppliers = []
      # Add suppliers found
      _suppliers.each do |i|
        _current_suppliers = _current_suppliers << i.offer_request_id
      end
      _current_suppliers
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
