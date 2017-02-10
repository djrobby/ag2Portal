require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CommercialBillingsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    #load_and_authorize_resource (error: model class does not exist)
    # Must authorize manually for every action in this controller
    skip_load_and_authorize_resource :only => [:ci_generate_no,
                                               :ci_update_selects_from_organization,
                                               :ci_update_offer_select_from_client,
                                               :ci_update_selects_from_offer,
                                               :ci_update_selects_from_project,
                                               :ci_format_number,
                                               :ci_format_number_4,
                                               :ci_item_totals,
                                               :ci_update_description_prices_from_product,
                                               :ci_update_product_select_from_offer_item,
                                               :ci_update_amount_from_price_or_quantity,
                                               :ci_item_balance_check,
                                               :ci_item_totals,
                                               :ci_generate_invoice,
                                               :ci_current_balance,
                                               :send_invoice_form,
                                               :invoice_form,
                                               :bill_create, :bill_update]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit
    # => returns client code & full name
    helper_method :client_name

    # Update invoice number at view (generate_code_btn)
    def ci_generate_no
      p = params[:project]
      code = '$err'

      # Builds no, if possible
      if p != '$'
        project = Project.find(p) rescue nil
        if !project.blank?
          code = commercial_bill_next_no(project.company_id, project.office_id)
        end
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update selects at view from organization
    def ci_update_selects_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @clients = @organization.blank? ? clients_dropdown : @organization.clients.order(:client_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.expenditures
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
      # Work orders array
      @orders_dropdown = orders_array(@work_orders)
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "client" => @clients, "project" => @projects, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown }
      render json: @json_data
    end

    # Update sale offer select at view from client
    def ci_update_offer_select_from_client
      client = params[:client]
      if client != '0'
        @client = Client.find(client)
        @sale_offers = @client.blank? ? sale_offers_dropdown : @client.sale_offers.unbilled_balance(@client.organization_id, true)
      else
        @sale_offers = sale_offers_dropdown
      end
      # Notes array
      @offers_dropdown = offers_array(@sale_offers)
      # Setup JSON
      @json_data = { "note" => @offers_dropdown }
      render json: @json_data
    end

    # Update selects at view from sale offer
    def ci_update_selects_from_offer
      o = params[:o]
      project_id = 0
      work_order_id = 0
      charge_account_id = 0
      store_id = 0
      payment_method_id = 0
      if o != '0'
        @sale_offer = SaleOffer.find(o)
        @offer_items = @sale_offer.blank? ? [] : offer_items_dropdown(@sale_offer)
        @projects = @sale_offer.blank? ? projects_dropdown : @sale_offer.project
        @work_orders = @sale_offer.blank? ? work_orders_dropdown : WorkOrder.where(id: @sale_offer.work_order)
        @charge_accounts = @sale_offer.blank? ? charge_accounts_dropdown : @sale_offer.charge_account
        @stores = @sale_offer.blank? ? stores_dropdown : @sale_offer.store
        @payment_methods = @sale_offer.blank? ? payment_methods_dropdown : @sale_offer.payment_method
        if @offer_items.blank?
          @products = @sale_offer.blank? ? products_dropdown : @sale_offer.organization.products.order(:product_code)
        else
          @products = @sale_offer.products.group(:product_code)
        end
        project_id = @projects.id rescue 0
        work_order_id = @work_orders.id rescue 0
        charge_account_id = @charge_accounts.id rescue 0
        store_id = @stores.id rescue 0
        payment_method_id = @payment_methods.id rescue 0
      else
        @offer_items = []
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Work orders array
      @orders_dropdown = orders_array(@work_orders)
      # Offer items array
      @offer_items_dropdown = offer_items_array(@offer_items)
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id, "note_item" => @offer_items_dropdown }
      render json: @json_data
    end

    # Update selects at view from project
    def ci_update_selects_from_project
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
      # Work orders array
      @orders_dropdown = orders_array(@work_order)
      # Setup JSON
      @json_data = { "work_order" => @orders_dropdown, "charge_account" => @charge_account, "store" => @store }
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
    def ci_item_totals
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
    def ci_update_description_prices_from_product
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

    # Update product select at view from sale offer item
    def ci_update_product_select_from_offer_item
      i = params[:i]
      product_id = 0
      if i != '0'
        @item = SaleOfferItem.find(i)
        product_id = @item.blank? ? 0 : @item.product_id
      end
      # Setup JSON
      @json_data = { "product" => product_id }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def ci_update_amount_from_price_or_quantity
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

    # Is quantity greater than offer item unbilled balance?
    def ci_item_balance_check
      i = params[:i]
      qty = params[:qty].to_f / 10000
      bal = 0
      alert = ""
      if i != '0'
        bal = SaleOfferItem.find(i).unbilled_balance rescue 0
        if qty > bal
          qty = number_with_precision(qty.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          bal = number_with_precision(bal.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          alert = I18n.t("activerecord.models.invoice_item.quantity_greater_than_balance", qty: qty, bal: bal)
        end
      end
      # Setup JSON
      @json_data = { "alert" => alert }
      render json: @json_data
    end

    # Calculate and format item totals properly
    def ci_item_totals
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

    # Generate new invoice from sale offer
    def ci_generate_invoice
      supplier = params[:supplier]
      note = params[:request]
      invoice_no = params[:offer_no]
      invoice_date = params[:offer_date]  # YYYYMMDD
      invoice = nil
      invoice_item = nil
      code = ''

      if note != '0'
        receipt_note = ReceiptNote.find(note) rescue nil
        receipt_note_items = receipt_note.receipt_note_items rescue nil
        if !receipt_note.nil? && !receipt_note_items.nil?
          # Format offer_date
          invoice_date = (invoice_date[0..3] + '-' + invoice_date[4..5] + '-' + invoice_date[6..7]).to_date
          # Try to save new invoice
          invoice = SupplierInvoice.new
          invoice.invoice_no = invoice_no
          invoice.supplier_id = receipt_note.supplier_id
          invoice.payment_method_id = receipt_note.payment_method_id
          invoice.invoice_date = invoice_date
          invoice.discount_pct = receipt_note.discount_pct
          invoice.discount = receipt_note.discount
          invoice.project_id = receipt_note.project_id
          invoice.work_order_id = receipt_note.work_order_id
          invoice.charge_account_id = receipt_note.charge_account_id
          invoice.created_by = current_user.id if !current_user.nil?
          invoice.organization_id = receipt_note.organization_id
          invoice.receipt_note_id = receipt_note.id
          if invoice.save
            # Try to save new invoice items
            receipt_note_items.each do |i|
              if i.balance != 0 # Only items not billed yet
                invoice_item = SupplierInvoiceItem.new
                invoice_item.supplier_invoice_id = invoice.id
                invoice_item.receipt_note_id = i.receipt_note_id
                invoice_item.receipt_note_item_id = i.id
                invoice_item.product_id = i.product_id
                invoice_item.code = i.code
                invoice_item.description = i.description
                invoice_item.quantity = i.balance
                invoice_item.price = i.price
                invoice_item.discount_pct = i.discount_pct
                invoice_item.discount = i.discount
                invoice_item.tax_type_id = i.tax_type_id
                invoice_item.work_order_id = i.work_order_id
                invoice_item.charge_account_id = i.charge_account_id
                invoice_item.created_by = current_user.id if !current_user.nil?
                invoice_item.project_id = i.project_id
                if !invoice_item.save
                  # Can't save invoice item (exit)
                  code = '$write'
                  break
                end   # !invoice_item.save?
              end   # i.balance != 0
            end   # do |i|
          else
            # Can't save invoice
            code = '$write'
          end   # invoice.save?
        else
          # Receipt note or items not found
          code = '$err'
        end   # !receipt_note.nil? && !receipt_note_items.nil?
      else
        # Receipt note 0
        code = '$err'
      end   # note != '0'
      if code == ''
        code = I18n.t("ag2_purchase.supplier_invoices.generate_invoice_ok", var: invoice.id.to_s)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Update sale offer balance (unbilled) text field at view
    def ci_current_balance
      order = params[:order]
      current_balance = 0
      if order != '0'
        current_balance = SaleOffer.find(order).unbilled_balance rescue 0
      end
      # Format numbers
      current_balance = number_with_precision(current_balance.round(4), precision: 4)
      # Setup JSON
      @json_data = { "balance" => current_balance.to_s }
      render json: @json_data
    end

    #
    # Emission Methods
    #
    # Email Report (jQuery)
    def send_invoice_form
      code = send_email(params[:id])
      message = code == '$err' ? t(:send_error) : t(:send_ok)
      @json_data = { "code" => code, "message" => message }
      render json: @json_data
    end

    # Report form
    def invoice_form
      # Search invoice & items
      @invoice = Invoice.find(params[:id])
      @items = @invoice.invoice_items.order('id')

      title = t("activerecord.models.invoice.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@invoice.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    #
    # Default Methods
    #
    # GET /commercial_billings
    # GET /commercial_billings.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      client = params[:Client]
      subscriber = params[:Subscriber]
      status = params[:Status]
      type = params[:Type]
      operation = params[:Operation]
      biller = params[:Biller]
      period = params[:Period]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      # @clients = clients_dropdown if @clients.nil?
      # @subscribers = subscribers_dropdown if @subscribers.nil?
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @billers = billers_dropdown if @billers.nil?
      @periods = billing_periods_dropdown if @periods.nil?
      @sale_offers = sale_offers_dropdown if @sale_offers.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      current_types = @types.blank? ? [0] : current_types_for_index(@types)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = Invoice.search do
        with :invoice_type_id, current_types
        with :project_id, current_projects
        fulltext params[:search]
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !client.blank?
          fulltext client
        end
        if !subscriber.blank?
          fulltext subscriber
        end
        if !project.blank?
          with :project_id, project
        end
        if !status.blank?
          with :invoice_status_id, status
        end
        if !type.blank?
          with :invoice_type_id, type
        end
        if !operation.blank?
          with :invoice_operation_id, operation
        end
        if !biller.blank?
          with :biller_id, biller
        end
        if !period.blank?
          with :billing_period_id, period
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @invoices = @search.results

      # manually handle authorization
      authorize! :index, @invoices

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoices }
        format.js
      end
    end

    # GET /commercial_billings/1
    # GET /commercial_billings/1.json
    def show
      @breadcrumb = 'read'
      @invoice = Invoice.find(params[:id])
      @bill = @invoice.bill
      @items = @invoice.invoice_items.paginate(:page => params[:page], :per_page => per_page).order('id')

      # manually handle authorization
      authorize! :show, @invoice

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice }
      end
    end

    # GET /commercial_billings/new
    # GET /commercial_billings/new.json
    def new
      @breadcrumb = 'create'
      @invoice = Invoice.new
      @organizations, @include_blank = organizations_according_oco
      @sale_offers = sale_offers_dropdown
      @projects = projects_dropdown
      @charge_accounts = projects_charge_accounts(@projects)
      @clients = clients_dropdown
      @payment_methods = payment_methods_dropdown
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @products = products_dropdown
      @offer_items = []

      # manually handle authorization
      authorize! :new, @invoice

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice }
      end
    end

    # GET /commercial_billings/1/edit
    def edit
      @breadcrumb = 'update'
      @invoice = Invoice.find(params[:id])
      @organizations, @include_blank = organizations_according_oco
      @sale_offers = @invoice.bill.client.blank? ? sale_offers_dropdown : @invoice.bill.client.sale_offers.unbilled(@invoice.organization_id, true)
      @projects = projects_dropdown_edit(@invoice.bill.project)
      @project = @invoice.bill.project_id
      @charge_accounts = charge_accounts_dropdown_edit(@invoice.bill.project)
      @clients = clients_dropdown
      @client = @invoice.bill.client_id
      @payment_methods = @invoice.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@invoice.organization_id)
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @offer_items = @invoice.sale_offer.blank? ? [] : offer_items_dropdown(@invoice.sale_offer)
      if @offer_items.blank?
        @products = @invoice.organization.blank? ? products_dropdown : @invoice.organization.products(:product_code)
      else
        @products = @offer_items.first.sale_offer.products.group(:product_code)
      end

      # manually handle authorization
      authorize! :edit, @invoice
    end

    # POST /commercial_billings
    # POST /commercial_billings.json
    def create
      @breadcrumb = 'create'
      @invoice = Invoice.new(params[:invoice])
      @invoice.created_by = current_user.id if !current_user.nil?

      # manually handle authorization
      authorize! :create, @invoice

      respond_to do |format|
        #
        # Must create associated bill
        #
        bill_id = bill_create(params[:Project],
                              params[:Client],
                              params[:invoice][:invoice_date].to_date,
                              params[:invoice][:payment_method_id].to_i)
        @invoice.bill_id = bill_id == 0 ? nil : bill_id
        @invoice.invoice_operation_id = InvoiceOperation::INVOICE

        # Go on
        if @invoice.save
          format.html { redirect_to commercial_billing_path(@invoice), notice: crud_notice('created', @invoice) }
          format.json { render json: @invoice, status: :created, location: @invoice }
        else
          @organizations, @include_blank = organizations_according_oco
          @sale_offers = sale_offers_dropdown
          @projects = projects_dropdown
          @charge_accounts = projects_charge_accounts(@projects)
          @clients = clients_dropdown
          @payment_methods = payment_methods_dropdown
          @status = invoice_statuses_dropdown if @status.nil?
          @types = invoice_types_dropdown if @types.nil?
          @operations = invoice_operations_dropdown if @operations.nil?
          @products = products_dropdown
          @offer_items = []
          format.html { render action: "new" }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /commercial_billings/1
    # PUT /commercial_billings/1.json
    def update
      @breadcrumb = 'update'
      @invoice = Invoice.find(params[:id])

      items_changed = false
      if params[:invoice][:invoice_items_attributes]
        params[:invoice][:invoice_items_attributes].values.each do |new_item|
          current_item = InvoiceItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.description != new_item[:description]) ||
              (current_item.code != new_item[:code]) ||
              (current_item.subcode != new_item[:subcode]) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f) ||
              (current_item.price.to_f != new_item[:price].to_f) ||
              (current_item.discount_pct.to_f != new_item[:discount_pct].to_f) ||
              (current_item.discount.to_f != new_item[:discount].to_f) ||
              (current_item.tax_type_id.to_i != new_item[:tax_type_id].to_i) ||
              (current_item.sale_offer_id.to_i != new_item[:sale_offer_id].to_i) ||
              (current_item.sale_offer_item_id.to_i != new_item[:sale_offer_item_id].to_i) ||
              (current_item.measure_id.to_i != new_item[:measure_id].to_i)))
            items_changed = true
            break
          end
        end
      end
      master_changed = false
      if ((params[:invoice][:organization_id].to_i != @invoice.organization_id.to_i) ||
          (params[:invoice][:invoice_no].to_s != @invoice.invoice_no) ||
          (params[:invoice][:invoice_date].to_date != @invoice.invoice_date) ||
          (params[:invoice][:sale_offer_id].to_i != @invoice.sale_offer_id.to_i) ||
          (params[:invoice][:charge_account_id].to_i != @invoice.charge_account_id.to_i) ||
          (params[:invoice][:payment_method_id].to_i != @invoice.payment_method_id.to_i) ||
          (params[:invoice][:discount_pct].to_f != @invoice.discount_pct.to_f) ||
          (params[:invoice][:remarks].to_s != @invoice.remarks))
        master_changed = true
      end

      # manually handle authorization
      authorize! :update, @invoice

      respond_to do |format|
        if master_changed || items_changed
          @invoice.updated_by = current_user.id if !current_user.nil?
          if @invoice.update_attributes(params[:invoice])
            #
            # Must update associated bill
            #
            bill_update(@invoice.bill,
                        params[:Project],
                        params[:Client],
                        params[:invoice][:invoice_date].to_date,
                        params[:invoice][:payment_method_id].to_i)

            # Go on
            format.html { redirect_to commercial_billing_path(@invoice),
                          notice: (crud_notice('updated', @invoice) + "#{undo_link(@invoice)}").html_safe }
            format.json { head :no_content }
          else
            @sale_offers = @invoice.bill.client.blank? ? sale_offers_dropdown : @invoice.bill.client.sale_offers.unbilled(@invoice.organization_id, true)
            @projects = projects_dropdown_edit(@invoice.bill.project)
            @charge_accounts = charge_accounts_dropdown_edit(@invoice.bill.project)
            @clients = clients_dropdown
            @payment_methods = @invoice.organization.blank? ? payment_methods_dropdown : collection_payment_methods(@invoice.organization_id)
            @offer_items = @invoice.sale_offer.blank? ? [] : offer_items_dropdown(@invoice.sale_offer)
            if @offer_items.blank?
              @products = @invoice.organization.blank? ? products_dropdown : @invoice.organization.products(:product_code)
            else
              @products = @offer_items.first.sale_offer.products.group(:product_code)
            end
            format.html { render action: "edit" }
            format.json { render json: @invoice.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to commercial_billing_path(@invoice) }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /commercial_billings/1
    # DELETE /commercial_billings/1.json
    def destroy
      @invoice = Invoice.find(params[:id])

      # manually handle authorization
      authorize! :destroy, @invoice

      respond_to do |format|
        if @invoice.destroy
          #
          # Must delete associated bill after
          #
          @invoice.bill.delete
          # Go on
          format.html { redirect_to commercial_billings_url,
                      notice: (crud_notice('destroyed', @invoice) + "#{undo_link(@invoice)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to commercial_billings_url, alert: "#{@invoice.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Invoice is charged
    def cannot_edit(_invoice)
      !session[:is_administrator] && _invoice.invoice_statuses_id != InvoiceStatus::PENDING
    end

    def client_name(_invoice)
      _name = _invoice.bill.client.full_name_or_company_and_code rescue nil
      _name.blank? ? '' : _name[0,40]
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def current_types_for_index(_types)
      _current_types = []
      _types.each do |i|
        _current_types = _current_types << i.id
      end
      _current_types
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Invoice.where('invoice_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.invoice_no
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
      _projects = Project.where(id: _array).order(:project_code)
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def this_current_projects_ids
      projects_dropdown.pluck(:id)
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _ret = ChargeAccount.incomes(project_id: _projects)
      ret_array(_array, _ret, 'id')
      # _projects.each do |i|
      #   _ret = ChargeAccount.incomes(i.id)
      #   ret_array(_array, _ret, 'id')
      # end

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

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.incomes.where(organization_id: session[:organization].to_i) : ChargeAccount.incomes
    end

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.incomes.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
    end

    def clients_dropdown
      session[:organization] != '0' ? Client.belongs_to_organization(session[:organization].to_i) : Client.by_code
    end

    def subscribers_dropdown
      session[:office] != '0' ? Subscriber.belongs_to_office(session[:office].to_i) : Subscriber.by_code
    end

    def billing_periods_dropdown
      !this_current_projects_ids.blank? ? BillingPeriod.belongs_to_projects(this_current_projects_ids) : BillingPeriod.by_period
    end

    def invoice_statuses_dropdown
      InvoiceStatus.all
    end

    def invoice_types_dropdown
      InvoiceType.commercial
    end

    def invoice_operations_dropdown
      InvoiceOperation.all
    end

    def billers_dropdown
      session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
    end

    def sale_offers_dropdown
      session[:organization] != '0' ? SaleOffer.unbilled(session[:organization].to_i, true) : SaleOffer.unbilled(nil, true)
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

    def offer_items_dropdown(_offer)
      _offer.sale_offer_items.joins(:sale_offer_item_balance).where('sale_offer_item_balances.balance > ?', 0)
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def offers_array(_offers)
      _array = []
      _offers.each do |i|
        _array = _array << [i.id, i.offer_no, formatted_date(i.offer_date), i.client.full_name]
      end
      _array
    end

    def offer_items_array(_offer_items)
      _array = []
      _offer_items.each do |i|
        _array = _array << [ i.id, i.id.to_s + ":", i.product.full_code, i.description[0,20],
                           (!i.quantity.blank? ? formatted_number(i.quantity, 4) : formatted_number(0, 4)),
                           (!i.net_price.blank? ? formatted_number(i.net_price, 4) : formatted_number(0, 4)),
                           (!i.amount.blank? ? formatted_number(i.amount, 4) : formatted_number(0, 4)),
                           "(" + (!i.unbilled_balance.blank? ? formatted_number(i.unbilled_balance, 4) : formatted_number(0, 4)) + ")" ]
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

    def orders_array(_orders)
      _array = []
      _orders.each do |i|
        _array = _array << [i.id, i.full_name]
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

      # Search invoice & items
      @invoice = Invoice.find(_invoice)
      @items = @invoice.invoice_items.order(:id)

      title = t("activerecord.models.invoice.one") + "_" + @invoice.full_no + ".pdf"
      pdf = render_to_string(filename: "#{title}", type: 'application/pdf')
      from = !current_user.nil? ? User.find(current_user.id).email : User.find(@invoice.created_by).email
      to = !@invoice.bill.client.email.blank? ? @invoice.bill.client.email : nil

      if from.blank? || to.blank?
        code = "$err"
      else
        # Send e-mail
        Notifier.send_invoice(@invoice, from, to, title, pdf).deliver
      end

      code
    end

    # Create associated Bill
    def bill_create(_project, _client, _date, _payment_method)
      _r = 0
      _bill = Bill.new
      _bill.created_by = current_user.id if !current_user.nil?
      _bill.bill_no = bill_next_no(_project)
      bill_assign(_bill, _project, _client, _date, _payment_method)
      if _bill.save
        _r = _bill.id
      end
      _r
    end

    # Update associated Bill
    def bill_update(_b, _project, _client, _date, _payment_method)
      _r = false
      _bill = Bill.find(_b) rescue nil
      if !_bill.nil?
        _bill.updated_by = current_user.id if !current_user.nil?
        bill_assign(_bill, _project, _client, _date, _payment_method)
        if _bill.save
          _r = true
        end
      end
      _r
    end

    def bill_assign(_bill, _project, _client, _date, _payment_method)
      _c = Client.find(_client) rescue nil
      _p = Project.find(_project) rescue nil
      if !_c.nil? && !_p.nil?
        _bill.project_id = _project
        _bill.client_id = _client
        _bill.bill_date = _date
        _bill.invoice_status_id = InvoiceStatus::PENDING
        _bill.last_name = _c.last_name
        _bill.first_name = _c.first_name
        _bill.company = _c.company
        _bill.fiscal_id = _c.fiscal_id
        _bill.street_type_id = _c.street_type_id
        _bill.street_name = _c.street_name
        _bill.street_number = _c.street_number
        _bill.building = _c.building
        _bill.floor = _c.floor
        _bill.floor_office = _c.floor_office
        _bill.zipcode_id = _c.zipcode_id
        _bill.town_id = _c.town_id
        _bill.province_id = _c.province_id
        _bill.region_id = _c.region_id
        _bill.country_id = _c.country_id
        _bill.organization_id = _p.organization_id
        _bill.payment_method_id = _payment_method
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
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # client
      if params[:Client]
        session[:Client] = params[:Client]
      elsif session[:Client]
        params[:Client] = session[:Client]
      end
      # subscriber
      if params[:Subscriber]
        session[:Subscriber] = params[:Subscriber]
      elsif session[:Subscriber]
        params[:Subscriber] = session[:Subscriber]
      end
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end
      # operation
      if params[:Operation]
        session[:Operation] = params[:Operation]
      elsif session[:Operation]
        params[:Operation] = session[:Operation]
      end
      # biller
      if params[:Biller]
        session[:Biller] = params[:Biller]
      elsif session[:Biller]
        params[:Biller] = session[:Biller]
      end
      # period
      if params[:Request]
        session[:Request] = params[:Request]
      elsif session[:Request]
        params[:Request] = session[:Request]
      end
    end
  end
end
