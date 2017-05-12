require_dependency "ag2_products/application_controller"

module Ag2Products
  class ReceiptNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:rn_remove_filters,
                                               :rn_restore_filters,
                                               :rn_totals,
                                               :rn_update_description_prices_from_product_store,
                                               :rn_update_description_prices_from_product,
                                               :rn_update_amount_from_price_or_quantity,
                                               :rn_update_charge_account_from_order,
                                               :rn_update_charge_account_from_project,
                                               :rn_update_order_select_from_supplier,
                                               :rn_update_selects_from_order,
                                               :rn_update_product_select_from_order_item,
                                               :rn_item_balance_check,
                                               :rn_format_number,
                                               :rn_current_stock,
                                               :rn_update_project_textfields_from_organization,
                                               :rn_update_product_select_from_organization,
                                               :receipt_notes_report,
                                               :rn_generate_note,
                                               :rn_attachment_changed,
                                               :rn_update_attachment,
                                               :receive_meters]
    # Helper methods for
    # => index filters
    helper_method :rn_remove_filters, :rn_restore_filters

    # Public attachment for drag&drop
    $attachment = nil
    $attachment_changed = false

    # Attachment has changed
    def rn_attachment_changed
      $attachment_changed = true
    end

    # Update attached file from drag&drop
    def rn_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment_changed = true
      $attachment.avatar = params[:file]
      $attachment.id = 1
      $attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end

    # Update purchase order select at view from supplier select
    def rn_update_order_select_from_supplier
      supplier = params[:supplier]
      _projects = projects_dropdown
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @orders = @supplier.blank? ? orders_dropdown(_projects) : @supplier.purchase_orders.undelivered_by_project(_projects, @supplier.organization_id, true)
      else
        @orders = orders_dropdown(_projects)
      end
      # Orders array
      @orders_dropdown = orders_array(@orders)
      # Setup JSON
      @json_data = { "order" => @orders_dropdown }
      render json: @json_data
    end

    # Update selects at view from purchase order
    def rn_update_selects_from_order
      o = params[:o]
      project_id = 0
      work_order_id = 0
      charge_account_id = 0
      store_id = 0
      payment_method_id = 0
      if o != '0'
        @order = PurchaseOrder.find(o)
        if @order.blank?
          @order_items = []
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown_new
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @payment_methods = payment_methods_dropdown
        else
          @order_items = order_items_dropdown(@order)
          @projects = @order.project
          @work_orders = WorkOrder.where(id: @order.work_order)
          @charge_accounts = @order.charge_account.blank? ? charge_accounts_dropdown : @order.charge_account
          @stores = @order.store.blank? ? project_stores(@projects) : @order.store
          @payment_methods = @order.payment_method.blank? ? payment_methods_dropdown : @order.payment_method
        end
        if @order_items.blank?
          @products = @order.blank? ? products_dropdown : @order.organization.products.order(:product_code)
        else
          @products = @order.products.group(:product_code)
        end
        project_id = @projects.id rescue 0
        work_order_id = @work_orders.id rescue 0
        charge_account_id = @charge_accounts.id rescue 0
        store_id = @stores.id rescue 0
        payment_method_id = @payment_methods.id rescue 0
      else
        @order_items = []
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown_new
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Work orders array
      @orders_dropdown = work_orders_array(@work_orders)
      # Order items array
      @order_items_dropdown = order_items_array(@order_items)
      # Products array
      @products_dropdown = products_array(@products)
      # Confirms that instance variables has data
      @charge_accounts = @charge_accounts.blank? ? charge_accounts_dropdown : @charge_accounts
      @stores = @stores.blank? ? stores_dropdown : @stores
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id, "order_item" => @order_items_dropdown }
      render json: @json_data
    end

    # Update product select at view from organization select
    def rn_update_product_select_from_organization
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

    # Update product select at view from purchase order item
    def rn_update_product_select_from_order_item
      i = params[:i]
      product_id = 0
      if i != '0'
        @item = PurchaseOrderItem.find(i)
        product_id = @item.blank? ? 0 : @item.product_id
      end
      # Setup JSON
      @json_data = { "product" => product_id }
      render json: @json_data
    end

    # Is quantity greater than item remaining balance?
    def rn_item_balance_check
      i = params[:i]
      qty = params[:qty].to_f / 10000
      bal = 0
      alert = ""
      if i != '0'
        bal = PurchaseOrderItem.find(i).balance rescue 0
        if qty > bal
          qty = number_with_precision(qty.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          bal = number_with_precision(bal.round(4), precision: 4, delimiter: I18n.locale == :es ? "." : ",")
          alert = I18n.t("activerecord.models.receipt_note_item.quantity_greater_than_balance", qty: qty, bal: bal)
        end
      end
      # Setup JSON
      @json_data = { "alert" => alert }
      render json: @json_data
    end

    # Calculate and format totals properly
    def rn_totals
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
    def rn_update_description_prices_from_product_store
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
                     "discountp" => discount_p, "discount" => discount, "code" => code, "tbl" => tbl.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def rn_update_description_prices_from_product
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
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id,
                     "discountp" => discount_p, "discount" => discount, "code" => code }
      render json: @json_data
    end

    # Update amount and tax text fields at view (quantity or price changed)
    def rn_update_amount_from_price_or_quantity
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

    # Update charge account and store text fields at view from work order select
    def rn_update_charge_account_from_order
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
    def rn_update_charge_account_from_project
      project = params[:order]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? work_orders_dropdown_new : @project.work_orders.by_no
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
        @store = project_stores(@project)
      else
        @work_order = work_orders_dropdown_new
        @charge_account = projects_charge_accounts(projects)
        @store = stores_dropdown
      end
      # Work orders array
      @orders_dropdown = work_orders_array(@work_order)
      # Setup JSON
      @json_data = { "work_order" => @orders_dropdown, "charge_account" => @charge_account, "store" => @store }
      render json: @json_data
    end

    # Format numbers properly
    def rn_format_number
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Update current stock text field at view from store select
    def rn_current_stock
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
    def rn_update_project_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @suppliers = @organization.blank? ? suppliers_dropdown : @organization.suppliers.order(:supplier_code)
        @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
        @work_orders = @organization.blank? ? work_orders_dropdown_new : @organization.work_orders.by_no
        @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.expenditures
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : payment_payment_methods(@organization.id)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @suppliers = suppliers_dropdown
        @projects = projects_dropdown
        @work_orders = work_orders_dropdown_new
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Work orders array
      @orders_dropdown = work_orders_array(@work_orders)
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "supplier" => @suppliers, "project" => @projects, "work_order" => @orders_dropdown,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown }
      render json: @json_data
    end

    # Update current balance text field at view from order select
    def rn_current_balance
      order = params[:order]
      current_balance = 0
      if order != '0'
        current_balance = PurchaseOrder.find(order).balance rescue 0
      end
      # Format numbers
      current_balance = number_with_precision(current_balance.round(4), precision: 4)
      # Setup JSON
      @json_data = { "balance" => current_balance.to_s }
      render json: @json_data
    end

    # Generate new receipt note from purchase order
    def rn_generate_note
      supplier = params[:supplier]
      order = params[:request]
      note_no = params[:offer_no]
      note_date = params[:offer_date]  # YYYYMMDD
      note = nil
      note_item = nil
      code = ''

      if order != '0'
        purchase_order = PurchaseOrder.find(order) rescue nil
        purchase_order_items = purchase_order.purchase_order_items rescue nil
        if !purchase_order.nil? && !purchase_order_items.nil?
          # Format offer_date
          note_date = (note_date[0..3] + '-' + note_date[4..5] + '-' + note_date[6..7]).to_date
          # Try to save new note
          note = ReceiptNote.new
          note.receipt_no = note_no
          note.supplier_id = purchase_order.supplier_id
          note.payment_method_id = purchase_order.payment_method_id
          note.receipt_date = note_date
          note.discount_pct = purchase_order.discount_pct
          note.discount = purchase_order.discount
          note.project_id = purchase_order.project_id
          note.store_id = purchase_order.store_id
          note.work_order_id = purchase_order.work_order_id
          note.charge_account_id = purchase_order.charge_account_id
          note.retention_pct = purchase_order.retention_pct
          note.retention_time = purchase_order.retention_time
          note.created_by = current_user.id if !current_user.nil?
          note.purchase_order_id = purchase_order.id
          note.organization_id = purchase_order.organization_id
          if note.save
            # Try to save new note items
            purchase_order_items.each do |i|
              if i.balance != 0 # Only items not received yet
                note_item = ReceiptNoteItem.new
                note_item.receipt_note_id = note.id
                note_item.purchase_order_item_id = i.id
                note_item.product_id = i.product_id
                note_item.description = i.description
                note_item.quantity = i.balance
                note_item.price = i.price
                note_item.discount_pct = i.discount_pct
                note_item.discount = i.discount
                note_item.tax_type_id = i.tax_type_id
                note_item.store_id = i.store_id
                note_item.work_order_id = i.work_order_id
                note_item.charge_account_id = i.charge_account_id
                note_item.created_by = current_user.id if !current_user.nil?
                note_item.code = i.code
                note_item.purchase_order_id = i.purchase_order_id
                note_item.project_id = i.project_id
                if !note_item.save
                  # Can't save note item (exit)
                  code = '$write'
                  break
                end   # !note_item.save?
              end   # i.balance != 0
            end   # do |i|
            # Update totals
            note.update_column(:totals, ReceiptNote.find(note.id).total)
          else
            # Can't save note
            code = '$write'
          end   # note.save?
        else
          # Purchase order or items not found
          code = '$err'
        end   # !purchase_order_items.nil? && !purchase_order_items.nil?
      else
        # Purchase order 0
        code = '$err'
      end   # order != '0'
      if code == ''
        code = I18n.t("ag2_products.receipt_notes.generate_note_ok", var: note.id.to_s)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /receipt_notes
    # GET /receipt_notes.json
    def index
      manage_filter_state
      no = params[:No]
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @supplier = !supplier.blank? ? Supplier.find(supplier).full_name : " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @work_order = !order.blank? ? WorkOrder.find(order).full_name : " "

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      @orders = orders_dropdown(@projects) if @orders.nil?
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = ReceiptNote.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :receipt_no, no
          else
            with(:receipt_no).starting_with(no)
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
        data_accessor_for(ReceiptNote).include = [:supplier, :project, :products, :purchase_order]
        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @receipt_notes = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @receipt_notes }
        format.js
      end
    end

    # GET /receipt_notes/1
    # GET /receipt_notes/1.json
    def show
      @breadcrumb = 'read'
      @receipt_note = ReceiptNote.find(params[:id])
      @items = @receipt_note.receipt_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @receipt_note }
      end
    end

    # GET /receipt_notes/new
    # GET /receipt_notes/new.json
    def new
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new
      $attachment_changed = false
      $attachment = Attachment.new
      destroy_attachment
      @projects = projects_dropdown
      @orders = orders_dropdown(@projects)
      # @work_orders = work_orders_dropdown
      @work_orders = work_orders_dropdown_new
      @charge_accounts = projects_charge_accounts(@projects)
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @payment_methods = payment_methods_dropdown
      # @products = products_dropdown
      # @order_items = []

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @receipt_note }
      end
    end

    # GET /receipt_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
      $attachment_changed = false
      $attachment = Attachment.new
      destroy_attachment
      @orders = @receipt_note.supplier.blank? ? orders_dropdown : orders_dropdown_edit(@receipt_note)
      # @orders = @receipt_note.supplier.blank? ? orders_dropdown : @receipt_note.supplier.purchase_orders.undelivered(@receipt_note.organization_id, true)
      @projects = projects_dropdown_edit(@receipt_note.project)
      # @work_orders = @receipt_note.project.blank? ? work_orders_dropdown : @receipt_note.project.work_orders.order(:order_no)
      @work_orders = @receipt_note.project.blank? ? work_orders_dropdown_new : work_orders_dropdown_edit(@receipt_note)
      @charge_accounts = work_order_charge_account(@receipt_note)
      @stores = work_order_store(@receipt_note)
      @suppliers = @receipt_note.organization.blank? ? suppliers_dropdown : @receipt_note.organization.suppliers(:supplier_code)
      @payment_methods = @receipt_note.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@receipt_note.organization_id)
      # @order_items = @receipt_note.purchase_order.blank? ? [] : order_items_dropdown(@receipt_note.purchase_order)
      # if @order_items.blank?
      #   @products = @receipt_note.organization.blank? ? products_dropdown : @receipt_note.organization.products(:product_code)
      # else
      #   @products = @order_items.first.purchase_order.products.group(:product_code)
      # end
    end

    # POST /receipt_notes
    # POST /receipt_notes.json
    def create
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new(params[:receipt_note])
      @receipt_note.created_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if @receipt_note.attachment.blank? && !$attachment.avatar.blank?
        @receipt_note.attachment = $attachment.avatar
      end

      respond_to do |format|
        $attachment_changed = false
        if @receipt_note.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @receipt_note, notice: crud_notice('created', @receipt_note) }
          format.json { render json: @receipt_note, status: :created, location: @receipt_note }
        else
          $attachment.destroy
          $attachment = Attachment.new
          @orders = orders_dropdown
          @projects = projects_dropdown
          @work_orders = work_orders_dropdown_new
          @charge_accounts = projects_charge_accounts(@projects)
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @payment_methods = payment_methods_dropdown
          # @products = products_dropdown
          # @order_items = []
          format.html { render action: "new" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /receipt_notes/1
    # PUT /receipt_notes/1.json
    def update
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])

      master_changed = false
      # Should use attachment from drag&drop?
      if $attachment != nil && !$attachment.avatar.blank? && $attachment.updated_at > @receipt_note.updated_at
        @receipt_note.attachment = $attachment.avatar
      end
      if @receipt_note.attachment.dirty? || $attachment_changed
        master_changed = true
      end

      items_changed = false
      if params[:receipt_note][:receipt_note_items_attributes]
        params[:receipt_note][:receipt_note_items_attributes].values.each do |new_item|
          current_item = ReceiptNoteItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.description != new_item[:description]) ||
              (current_item.code != new_item[:code]) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f) ||
              (current_item.price.to_f != new_item[:price].to_f) ||
              (current_item.discount_pct.to_f != new_item[:discount_pct].to_f) ||
              (current_item.discount.to_f != new_item[:discount].to_f) ||
              (current_item.tax_type_id.to_i != new_item[:tax_type_id].to_i) ||
              (current_item.purchase_order_id.to_i != new_item[:purchase_order_id].to_i) ||
              (current_item.purchase_order_item_id.to_i != new_item[:purchase_order_item_id].to_i) ||
              (current_item.project_id.to_i != new_item[:project_id].to_i) ||
              (current_item.work_order_id.to_i != new_item[:work_order_id].to_i) ||
              (current_item.charge_account_id.to_i != new_item[:charge_account_id].to_i) ||
              (current_item.store_id.to_i != new_item[:store_id].to_i)))
            items_changed = true
            break
          end
        end
      end
      if ((params[:receipt_note][:organization_id].to_i != @receipt_note.organization_id.to_i) ||
          (params[:receipt_note][:project_id].to_i != @receipt_note.project_id.to_i) ||
          (params[:receipt_note][:receipt_no].to_s != @receipt_note.receipt_no) ||
          (params[:receipt_note][:receipt_date].to_date != @receipt_note.receipt_date) ||
          (params[:receipt_note][:supplier_id].to_i != @receipt_note.supplier_id.to_i) ||
          (params[:receipt_note][:purchase_order_id].to_i != @receipt_note.purchase_order_id.to_i) ||
          (params[:receipt_note][:work_order_id].to_i != @receipt_note.work_order_id.to_i) ||
          (params[:receipt_note][:charge_account_id].to_i != @receipt_note.charge_account_id.to_i) ||
          (params[:receipt_note][:store_id].to_i != @receipt_note.store_id.to_i) ||
          (params[:receipt_note][:payment_method_id].to_i != @receipt_note.payment_method_id.to_i) ||
          (params[:receipt_note][:retention_pct].to_f != @receipt_note.retention_pct.to_f) ||
          (params[:receipt_note][:retention_time].to_i != @receipt_note.retention_time.to_i) ||
          (params[:receipt_note][:discount_pct].to_f != @receipt_note.discount_pct.to_f) ||
          (params[:receipt_note][:remarks].to_s != @receipt_note.remarks))
        master_changed = true
      end

      respond_to do |format|
        if master_changed || items_changed
          @receipt_note.updated_by = current_user.id if !current_user.nil?
          $attachment_changed = false
          if @receipt_note.update_attributes(params[:receipt_note])
            destroy_attachment
            $attachment = nil
            format.html { redirect_to @receipt_note,
                          notice: (crud_notice('updated', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
            format.json { head :no_content }
          else
            destroy_attachment
            $attachment = Attachment.new
            @orders = @receipt_note.supplier.blank? ? orders_dropdown : orders_dropdown_edit(@receipt_note)
            @projects = projects_dropdown_edit(@receipt_note.project)
            @work_orders = @receipt_note.project.blank? ? work_orders_dropdown_new : work_orders_dropdown_edit(@receipt_note)
            @charge_accounts = work_order_charge_account(@receipt_note)
            @stores = work_order_store(@receipt_note)
            @suppliers = @receipt_note.organization.blank? ? suppliers_dropdown : @receipt_note.organization.suppliers(:supplier_code)
            @payment_methods = @receipt_note.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@receipt_note.organization_id)
            # @order_items = @receipt_note.purchase_order.blank? ? [] : order_items_dropdown(@receipt_note.purchase_order)
            # if @order_items.blank?
            #   @products = @receipt_note.organization.blank? ? products_dropdown : @receipt_note.organization.products(:product_code)
            # else
            #   @products = @order_items.first.purchase_order.products.group(:product_code)
            # end
            format.html { render action: "edit" }
            format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @receipt_note }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /receipt_notes/1
    # DELETE /receipt_notes/1.json
    def destroy
      @receipt_note = ReceiptNote.find(params[:id])

      respond_to do |format|
        if @receipt_note.destroy
          format.html { redirect_to receipt_notes_url,
                      notice: (crud_notice('destroyed', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to receipt_notes_url, alert: "#{@receipt_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /receive_meters
    # GET /receive_meters.json
    def receive_meters
      @item = ReceiptNoteItem.find(params[:id])
      @receipt_note = @item.receipt_note
      @meter_models = meter_models_dropdown
      @calibers = calibers_dropdown

      respond_to do |format|
        format.html # receive_meters.html.erb
        format.json { render json: { :item => @item, :note => @receipt_note } }
      end
    end

    # Receipt notes report
    def receipt_notes_report
      manage_filter_state
      no = params[:No]
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]
      # OCO
      init_oco if !session[:organization]
      # Initialize projects for array search
      projects = projects_dropdown

      # Arrays for search
      current_projects = projects.blank? ? [0] : current_projects_for_index(projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = ReceiptNote.search do
        with :project_id, current_projects
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !no.blank?
          if no.class == Array
            with :receipt_no, no
          else
            with(:receipt_no).starting_with(no)
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
        paginate :page => params[:page] || 1, :per_page => ReceiptNote.count
      end

      @receipt_notes_report = @search.results

      if !@receipt_notes_report.blank?
        title = t("activerecord.models.receipt_note.few")
        @to = formatted_date(@receipt_notes_report.first.created_at)
        @from = formatted_date(@receipt_notes_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end
# MJ

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
      ReceiptNote.where('receipt_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.receipt_no
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
      _ret = ChargeAccount.expenditures.where(project_id: _projects)
      ret_array(_array, _ret, 'id')
      # _projects.each do |i|
      #   _ret = ChargeAccount.expenditures.where(project_id: i.id)
      #   ret_array(_array, _ret, 'id')
      # end

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

    def projects_dropdown_old
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
      session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    def orders_dropdown(_projects)
      if _projects.blank?
        session[:organization] != '0' ? PurchaseOrder.undelivered(session[:organization].to_i, true) : PurchaseOrder.undelivered(nil, true)
      else
        PurchaseOrder.undelivered_by_project(_projects, nil, true)
      end
    end

    def orders_dropdown_old
      session[:organization] != '0' ? PurchaseOrder.undelivered(session[:organization].to_i, true) : PurchaseOrder.undelivered(nil, true)
    end

    def orders_dropdown_edit(_receipt_note)
      _array = []
      _array = _array << _receipt_note.purchase_order_id unless _receipt_note.purchase_order_id.blank?
      ret_array(_array, _receipt_note.supplier.purchase_orders.undelivered(_receipt_note.organization_id, true), 'id')
      PurchaseOrder.these(_array)
    end

    def order_items_dropdown(_order)
      _order.purchase_order_items.joins(:purchase_order_item_balance).where('purchase_order_item_balances.balance > ?', 0)
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.expenditures.where(organization_id: session[:organization].to_i) : ChargeAccount.expenditures
    end

    def charge_accounts_dropdown_edit(_project)
      #_accounts = ChargeAccount.where('project_id = ? OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
      ChargeAccount.expenditures.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
    end

    def stores_dropdown
      _array = []
      _stores = nil
      _store_offices = nil

      if session[:office] != '0'
        _stores = Store.where(office_id: session[:office].to_i)
        _store_offices = StoreOffice.where("office_id = ?", session[:office].to_i)
      elsif session[:company] != '0'
        _stores = Store.where(company_id: session[:company].to_i)
      else
        _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i) : Store.order
      end

      # Returning founded stores
      ret_array(_array, _stores, 'id')
      ret_array(_array, _store_offices, 'store_id')
      _stores = Store.where(id: _array).order(:name)
    end

    def stores_dropdown_old
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def work_orders_dropdown_new
      session[:organization] != '0' ? WorkOrder.belongs_to_organization_unclosed(session[:organization].to_i) : WorkOrder.unclosed_only
    end

    def work_orders_dropdown_edit(_receipt_note)
      _array = []
      _items = _receipt_note.receipt_note_items.where('NOT work_order_id IS NULL')
      _array = _array << _receipt_note.work_order_id unless _receipt_note.work_order.blank?
      ret_array(_array, _items, 'work_order_id')
      WorkOrder.belongs_to_project_unclosed_and_this(_receipt_note.project_id, _array)
    end

    def payment_methods_dropdown
      session[:organization] != '0' ? payment_payment_methods(session[:organization].to_i) : payment_payment_methods(0)
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

    def meter_models_dropdown
      MeterModel.all
    end

    def calibers_dropdown
      Caliber.by_caliber
    end

    def orders_array(_orders)
      _array = []
      _orders.each do |i|
        _array = _array << [i.id, i.full_no, formatted_date(i.order_date), i.supplier.full_name]
      end
      _array
    end

    def order_items_array(_order_items)
      _array = []
      _order_items.each do |i|
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

    def work_orders_array(_orders)
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

    def rn_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Supplier] = ""
      params[:Project] = ""
      params[:Order] = ""
      return " "
    end

    def rn_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Supplier] = session[:Supplier]
      params[:Project] = session[:Project]
      params[:Order] = session[:Order]
    end
  end
end
