require_dependency "ag2_products/application_controller"

module Ag2Products
  class ReceiptNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:rn_totals,
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
                                               :rn_generate_note,
                                               :rn_update_attachment]
    # Public attachment for drag&drop
    $attachment = nil
  
    # Update attached file from drag&drop
    def rn_update_attachment
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

    # Update purchase order select at view from supplier select
    def rn_update_order_select_from_supplier
      supplier = params[:supplier]
      if supplier != '0'
        @supplier = Supplier.find(supplier)
        @orders = @supplier.blank? ? orders_dropdown : @supplier.purchase_orders.undelivered(@supplier.organization_id, true)
        #@orders = @supplier.blank? ? orders_dropdown : @supplier.purchase_orders.order(:supplier_id, :order_no, :id)
      else
        @orders = orders_dropdown
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
        @order_items = @order.blank? ? [] : order_items_dropdown(@order)
        @projects = @order.blank? ? projects_dropdown : @order.project
        @work_orders = @order.blank? ? work_orders_dropdown : @order.work_order
        @charge_accounts = @order.blank? ? charge_accounts_dropdown : @order.charge_account
        @stores = @order.blank? ? stores_dropdown : @order.store
        @payment_methods = @order.blank? ? payment_methods_dropdown : @order.payment_method
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
        @work_orders = work_orders_dropdown
        @charge_accounts = charge_accounts_dropdown
        @stores = stores_dropdown
        @payment_methods = payment_methods_dropdown
        @products = products_dropdown
      end
      # Order items array
      @order_items_dropdown = order_items_array(@order_items)
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "project" => @projects, "work_order" => @work_orders,
                     "charge_account" => @charge_accounts, "store" => @stores,
                     "payment_method" => @payment_methods, "product" => @products_dropdown,
                     "project_id" => project_id, "work_order_id" => work_order_id,
                     "charge_account_id" => charge_account_id, "store_id" => store_id,
                     "payment_method_id" => payment_method_id, "order_item" => @order_items_dropdown }
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
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id, "stock" => current_stock.to_s }
      render json: @json_data
    end

    # Update description and prices text fields at view from product select
    def rn_update_description_prices_from_product
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
      # Setup JSON hash
      @json_data = { "description" => description, "price" => price.to_s, "amount" => amount.to_s,
                     "tax" => tax.to_s, "type" => tax_type_id }
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

    # Update charge account and store text fields at view from work order select
    def rn_update_charge_account_from_order
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
    def rn_update_charge_account_from_project
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
            end   # do |i|
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
      @projects = projects_dropdown if @projects.nil?
      @suppliers = suppliers_dropdown if @suppliers.nil?
      @work_orders = work_orders_dropdown if @work_orders.nil?
      @orders = orders_dropdown if @orders.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
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
      $attachment = Attachment.new
      destroy_attachment
      @orders = orders_dropdown
      @projects = projects_dropdown
      @work_orders = work_orders_dropdown
      @charge_accounts = charge_accounts_dropdown
      @stores = stores_dropdown
      @suppliers = suppliers_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
      @order_items = []
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
      $attachment = Attachment.new
      destroy_attachment
      @orders = @receipt_note.supplier.blank? ? orders_dropdown : @receipt_note.supplier.purchase_orders.undelivered(@receipt_note.organization_id, true)
      @projects = projects_dropdown_edit(@receipt_note.project)
      @work_orders = @receipt_note.project.blank? ? work_orders_dropdown : @receipt_note.project.work_orders.order(:order_no)
      @charge_accounts = work_order_charge_account(@receipt_note)
      @stores = work_order_store(@receipt_note)
      @suppliers = @receipt_note.organization.blank? ? suppliers_dropdown : @receipt_note.organization.suppliers(:supplier_code)
      @payment_methods = @receipt_note.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@receipt_note.organization_id)
      @order_items = @receipt_note.purchase_order.blank? ? [] : order_items_dropdown(@receipt_note.purchase_order)
      #@products = @receipt_note.organization.blank? ? products_dropdown : @receipt_note.organization.products(:product_code)
      if @order_items.blank?
        @products = @receipt_note.organization.blank? ? products_dropdown : @receipt_note.organization.products(:product_code)
      else
        @products = @order_items.first.purchase_order.products.group(:product_code)
      end
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
          @work_orders = work_orders_dropdown
          @charge_accounts = charge_accounts_dropdown
          @stores = stores_dropdown
          @suppliers = suppliers_dropdown
          @payment_methods = payment_methods_dropdown
          @products = products_dropdown
          @order_items = []
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
      @receipt_note.updated_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if $attachment != nil && !$attachment.avatar.blank? && $attachment.updated_at > @receipt_note.updated_at
        @receipt_note.attachment = $attachment.avatar
      end
  
      respond_to do |format|
        if @receipt_note.update_attributes(params[:receipt_note])
          destroy_attachment
          $attachment = nil
          format.html { redirect_to @receipt_note,
                        notice: (crud_notice('updated', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
          format.json { head :no_content }
        else
          destroy_attachment
          $attachment = Attachment.new
          @orders = @receipt_note.supplier.blank? ? orders_dropdown : @receipt_note.supplier.purchase_orders.undelivered(@receipt_note.organization_id, true)
          @projects = projects_dropdown_edit(@receipt_note.project)
          @work_orders = @receipt_note.project.blank? ? work_orders_dropdown : @receipt_note.project.work_orders.order(:order_no)
          @charge_accounts = work_order_charge_account(@receipt_note)
          @stores = work_order_store(@receipt_note)
          @suppliers = @receipt_note.organization.blank? ? suppliers_dropdown : @receipt_note.organization.suppliers(:supplier_code)
          @payment_methods = @receipt_note.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@receipt_note.organization_id)
          @order_items = @receipt_note.purchase_order.blank? ? [] : order_items_dropdown(@receipt_note.purchase_order)
          if @order_items.blank?
            @products = @receipt_note.organization.blank? ? products_dropdown : @receipt_note.organization.products(:product_code)
          else
            @products = @order_items.first.products.group(:product_code)
          end
          format.html { render action: "edit" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
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

    def orders_dropdown
      session[:organization] != '0' ? PurchaseOrder.undelivered(session[:organization].to_i, true) : PurchaseOrder.undelivered(nil, true)
      #_orders = session[:organization] != '0' ? PurchaseOrder.where(organization_id: session[:organization].to_i).order(:supplier_id, :order_no, :id) : PurchaseOrder.order(:supplier_id, :order_no, :id)
    end
    
    def order_items_dropdown(_order)
      _order.purchase_order_items.joins(:purchase_order_item_balance).where('purchase_order_item_balances.balance > ?', 0)
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
