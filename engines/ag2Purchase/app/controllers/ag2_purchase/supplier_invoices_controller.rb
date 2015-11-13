require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierInvoicesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:si_update_receipt_select_from_supplier,
                                               :si_update_selects_from_note,
                                               :si_update_product_select_from_note_item,
                                               :si_item_balance_check,
                                               :si_item_totals,
                                               :si_approval_totals,
                                               :si_update_description_prices_from_product_store,
                                               :si_update_description_prices_from_product,
                                               :si_update_amount_from_price_or_quantity,
                                               :si_update_approved_amount,
                                               :si_current_invoice_debt,
                                               :si_update_charge_account_from_order,
                                               :si_update_charge_account_from_project,
                                               :si_format_number,
                                               :si_current_stock,
                                               :si_update_project_textfields_from_organization,
                                               :si_current_balance,
                                               :si_generate_invoice,
                                               :si_update_attachment]
    # Public attachment for drag&drop
    $attachment = nil
  
    # Update attached file from drag&drop
    def si_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment.avatar = params[:file]
      $attachment.id = 1
      $attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end

    # Update receipt note select at view from supplier select
    def si_update_receipt_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @receipt_notes = @supplier.blank? ? receipts_dropdown : @supplier.receipt_notes.unbilled(@supplier.organization_id, true)
        #@notes = @supplier.blank? ? receipts_dropdown : @supplier.receipt_notes.order(:supplier_id, :receipt_no, :id)
      else
        @receipt_notes = receipts_dropdown
      end
      # Notes array
      @notes_dropdown = notes_array(@receipt_notes)
      # Setup JSON
      @json_data = { "note" => @notes_dropdown }
      render json: @json_data
    end

    # Update selects at view from receipt note
    def si_update_selects_from_note
      o = params[:o]
      project_id = 0
      work_order_id = 0
      charge_account_id = 0
      store_id = 0
      payment_method_id = 0
      if o != '0'
        @receipt_note = ReceiptNote.find(o)
        @note_items = @receipt_note.blank? ? [] : note_items_dropdown(@receipt_note)
        @projects = @receipt_note.blank? ? projects_dropdown : @receipt_note.project
        @work_orders = @receipt_note.blank? ? work_orders_dropdown : @receipt_note.work_order
        @charge_accounts = @receipt_note.blank? ? charge_accounts_dropdown : @receipt_note.charge_account
        @stores = @receipt_note.blank? ? stores_dropdown : @receipt_note.store
        @payment_methods = @receipt_note.blank? ? payment_methods_dropdown : @receipt_note.payment_method
        if @note_items.blank?
          @products = @receipt_note.blank? ? products_dropdown : @receipt_note.organization.products.order(:product_code)
        else
          @products = @receipt_note.products.group(:product_code)
        end
        project_id = @projects.id rescue 0
        work_order_id = @work_orders.id rescue 0
        charge_account_id = @charge_accounts.id rescue 0
        store_id = @stores.id rescue 0
        payment_method_id = @payment_methods.id rescue 0
      else
        @note_items = []
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Note items array
      @note_items_dropdown = note_items_array(@note_items)
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id, "note_item" => @note_items_dropdown }
      render json: @json_data
    end

    # Update product select at view from receipt note item
    def si_update_product_select_from_note_item
      i = params[:i]
      product_id = 0
      if i != '0'
        @item = ReceiptNoteItem.find(i)
        product_id = @item.blank? ? 0 : @item.product_id
      end
      # Setup JSON
      @json_data = { "product" => product_id }
      render json: @json_data
    end

    # Is quantity greater than item unbilled balance?
    def si_item_balance_check
      i = params[:i]
      qty = params[:qty].to_f / 10000
      bal = 0
      alert = ""
      if i != '0'
        bal = ReceiptNoteItem.find(i).balance rescue 0
        if qty > bal
          qty = number_with_precision(qty.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          bal = number_with_precision(bal.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          alert = I18n.t("activerecord.models.supplier_invoice_item.quantity_greater_than_balance", qty: qty, bal: bal)
        end
      end
      # Setup JSON
      @json_data = { "alert" => alert }
      render json: @json_data
    end

    # Calculate and format item totals properly
    def si_item_totals
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

    # Calculate and format approval totals properly
    def si_approval_totals
      total = params[:amount].to_f / 10000
      # Format output values
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "total" => total.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product & store selects
    def si_update_description_prices_from_product_store
      product = params[:product]
      store = params[:store]
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
      current_stock = 0
      if product != '0'
        @product = Product.find(product)
        @prices = @product.purchase_prices
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
        if store != 0
          current_stock = Stock.find_by_product_and_store(product, store).current rescue 0
        end
      end
      # Format numbers
      price = number_with_precision(price.round(4), precision: 4)
      tax = number_with_precision(tax.round(4), precision: 4)
      amount = number_with_precision(amount.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      discount_p = number_with_precision(discount_p.round(2), precision: 2)
      discount = number_with_precision(discount.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s,
                     "discountp" => discount_p, "discount" => discount, "code" => code }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def si_update_description_prices_from_product
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
        @prices = @product.purchase_prices
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
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id,
                     "discountp" => discount_p, "discount" => discount, "code" => code }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def si_update_amount_from_price_or_quantity
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
      render json: @json_data
    end

    # Update approved amount text field, checking current debt (approved amount changed)
    def si_update_approved_amount
      amount = params[:amount].to_f / 10000
      invoice_id = params[:invoice]
      debt = SupplierInvoice.find(invoice_id).debt rescue -1
      not_yet_approved = SupplierInvoice.find(invoice_id).amount_not_yet_approved rescue -1
      amount = (amount > debt || amount > not_yet_approved) ? '$err' : number_with_precision(amount.round(4), precision: 4)
      @json_data = { "amount" => amount.to_s }
      render json: @json_data
    end
    
    # Current invoice debt
    def si_current_invoice_debt
      invoice_id = params[:invoice]
      debt = SupplierInvoice.find(invoice_id).debt rescue -1
      not_yet_approved = SupplierInvoice.find(invoice_id).amount_not_yet_approved rescue -1
      debt = debt < not_yet_approved ? number_with_precision(debt.round(4), precision: 4) : number_with_precision(not_yet_approved.round(4), precision: 4)
      @json_data = { "debt" => debt.to_s }
      render json: @json_data
    end
    
    # Update charge account and store text fields at view from work order select
    def si_update_charge_account_from_order
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
    def si_update_charge_account_from_project
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
    def si_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def si_current_stock
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
    def si_update_project_textfields_from_organization
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
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "supplier" => @suppliers, "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown }
      render json: @json_data
    end

    # Update receipt note balance (unbilled) text field at view from receipt select
    def si_current_balance
      order = params[:order]
      current_balance = 0
      if order != '0'
        current_balance = ReceiptNote.find(order).balance rescue 0
      end
      # Format numbers
      current_balance = number_with_precision(current_balance.round(4), precision: 4)
      # Setup JSON
      @json_data = { "balance" => current_balance.to_s }
      render json: @json_data
    end

    # Generate new invoice from receipt note
    def si_generate_invoice
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

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    def index
      manage_filter_state
      no = params[:No]
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @suppliers = suppliers_dropdown if @suppliers.nil?
      @work_orders = work_orders_dropdown if @work_orders.nil?
      @receipt_notes = receipts_dropdown if @receipt_notes.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      
      @search = SupplierInvoice.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
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
      @supplier_invoices = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_invoices }
        format.js
      end
    end
  
    # GET /supplier_invoices/1
    # GET /supplier_invoices/1.json
    def show
      @breadcrumb = 'read'
      @supplier_invoice = SupplierInvoice.find(params[:id])
      @items = @supplier_invoice.supplier_invoice_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @approvals = @supplier_invoice.supplier_invoice_approvals.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/new
    # GET /supplier_invoices/new.json
    def new
      @breadcrumb = 'create'
      @supplier_invoice = SupplierInvoice.new
      $attachment = Attachment.new
      destroy_attachment
      @receipt_notes = receipts_dropdown
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
      @note_items = []
      # Special to approvals
      @users = User.where('id = ?', current_user.id)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_invoice }
      end
    end
  
    # GET /supplier_invoices/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_invoice = SupplierInvoice.find(params[:id])
      $attachment = Attachment.new
      destroy_attachment
      # _form ivars
      @receipt_notes = @supplier_invoice.supplier.blank? ? receipts_dropdown : @supplier_invoice.supplier.receipt_notes.unbilled(@supplier_invoice.organization_id, true)
      @projects = projects_dropdown_edit(@supplier_invoice.project)
      @work_orders = @supplier_invoice.project.blank? ? work_orders_dropdown : @supplier_invoice.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@supplier_invoice)
      @stores = work_order_store(@supplier_invoice)
      @suppliers = suppliers_dropdown
      @payment_methods = @supplier_invoice.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@supplier_invoice.organization_id)      
      @note_items = @supplier_invoice.receipt_note.blank? ? [] : note_items_dropdown(@supplier_invoice.receipt_note)
      #@products = @supplier_invoice.organization.blank? ? products_dropdown : @supplier_invoice.organization.products(:product_code)
      if @note_items.blank?
        @products = @supplier_invoice.organization.blank? ? products_dropdown : @supplier_invoice.organization.products(:product_code)
      else
        @products = @note_items.first.receipt_note.products.group(:product_code)
      end
      # Special to approvals
      @invoice_debt = number_with_precision(@supplier_invoice.debt.round(4), precision: 4)
      @invoice_not_yet_approved = number_with_precision(@supplier_invoice.amount_not_yet_approved.round(4), precision: 4)
      @users = User.where('id = ?', current_user.id)
      @is_approver = company_approver(@supplier_invoice, @supplier_invoice.project.company, current_user.id) ||
                     office_approver(@supplier_invoice, @supplier_invoice.project.office, current_user.id) ||
                     (current_user.has_role? :Approver)
    end
  
    # POST /supplier_invoices
    # POST /supplier_invoices.json
    def create
      @breadcrumb = 'create'
      @supplier_invoice = SupplierInvoice.new(params[:supplier_invoice])
      @supplier_invoice.created_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if @supplier_invoice.attachment.blank? && !$attachment.avatar.blank?
        @supplier_invoice.attachment = $attachment.avatar
      end
  
      respond_to do |format|
        if @supplier_invoice.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @supplier_invoice, notice: crud_notice('created', @supplier_invoice) }
          format.json { render json: @supplier_invoice, status: :created, location: @supplier_invoice }
        else
          $attachment.destroy
          $attachment = Attachment.new
          @receipt_notes = receipts_dropdown
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          @note_items = []
          @users = User.where('id = ?', current_user.id)
          format.html { render action: "new" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /supplier_invoices/1
    # PUT /supplier_invoices/1.json
    def update
      @breadcrumb = 'update'
      @supplier_invoice = SupplierInvoice.find(params[:id])
      @supplier_invoice.updated_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if $attachment != nil && !$attachment.avatar.blank? && $attachment.updated_at > @supplier_invoice.updated_at
        @supplier_invoice.attachment = $attachment.avatar
      end
  
      respond_to do |format|
        if @supplier_invoice.update_attributes(params[:supplier_invoice])
          destroy_attachment
          $attachment = nil
          format.html { redirect_to @supplier_invoice,
                        notice: (crud_notice('updated', @supplier_invoice) + "#{undo_link(@supplier_invoice)}").html_safe }
          format.json { head :no_content }
        else
          destroy_attachment
          $attachment = Attachment.new
          @receipt_notes = @supplier_invoice.supplier.blank? ? receipts_dropdown : @supplier_invoice.supplier.receipt_notes.unbilled(@supplier_invoice.organization_id, true)
          @projects = projects_dropdown_edit(@supplier_invoice.project)
          @work_orders = @supplier_invoice.project.blank? ? work_orders_dropdown : @supplier_invoice.project.work_orders.order(:order_no)
          @charge_accounts = work_order_charge_account(@supplier_invoice)
          @stores = work_order_store(@supplier_invoice)
          @suppliers = suppliers_dropdown
          @payment_methods = @supplier_invoice.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@supplier_invoice.organization_id)      
          @note_items = @supplier_invoice.receipt_note.blank? ? [] : note_items_dropdown(@supplier_invoice.receipt_note)
          if @note_items.blank?
            @products = @supplier_invoice.organization.blank? ? products_dropdown : @supplier_invoice.organization.products(:product_code)
          else
            @products = @note_items.first.receipt_note.products.group(:product_code)
          end
          @users = User.where('id = ?', current_user.id)
          format.html { render action: "edit" }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /supplier_invoices/1
    # DELETE /supplier_invoices/1.json
    def destroy
      @supplier_invoice = SupplierInvoice.find(params[:id])

      respond_to do |format|
        if @supplier_invoice.destroy
          format.html { redirect_to supplier_invoices_url,
                      notice: (crud_notice('destroyed', @supplier_invoice) + "#{undo_link(@supplier_invoice)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to supplier_invoices_url, alert: "#{@supplier_invoice.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @supplier_invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    private
    
    def destroy_attachment
      if $attachment != nil
        $attachment.destroy        
      end
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
      SupplierInvoice.where('invoice_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.invoice_no
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

    def suppliers_dropdown
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def receipts_dropdown
      session[:organization] != '0' ? ReceiptNote.unbilled(session[:organization].to_i, true) : ReceiptNote.unbilled(nil, true)
    end
    
    def note_items_dropdown(_note)
      _note.receipt_note_items.joins(:receipt_note_item_balance).where('receipt_note_item_balances.balance > ?', 0)
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
    
    def notes_array(_notes)
      _array = []
      _notes.each do |i|
        _array = _array << [i.id, i.receipt_no, formatted_date(i.receipt_date), i.supplier.full_name] 
      end
      _array
    end
    
    def note_items_array(_note_items)
      _array = []
      _note_items.each do |i|
        _array = _array << [ i.id, i.id.to_s + ":", i.product.full_code, i.description[0,20],
                           (!i.quantity.blank? ? formatted_number(i.quantity, 4) : formatted_number(0, 4)),
                           (!i.net_price.blank? ? formatted_number(i.net_price, 4) : formatted_number(0, 4)),
                           (!i.amount.blank? ? formatted_number(i.amount, 4) : formatted_number(0, 4)),
                           "(" + (!i.balance.blank? ? formatted_number(i.balance, 4) : formatted_number(0, 4)) + ")" ]
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
