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
                                               :ic_update_from_organization,
                                               :inventory_count_form,
                                               :inventory_counts_report,
                                               :ic_products_from_organization]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit

    # Calculate and format totals properly
    def ic_totals
      qty = params[:qty].to_f / 10000
      total = params[:total].to_f / 10000
      tbl = params[:tbl]
      # Format output values
      qty = number_with_precision(qty.round(4), precision: 4)
      total = number_with_precision(total.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "qty" => qty.to_s, "tbl" => tbl.to_s, "total" => total.to_s }
      render json: @json_data
    end

    # Update product & family select at view from store
    def ic_update_family_select_from_store
      store = params[:store]
      type = params[:type].to_i
      if store != '0' && type != 1
        @store = Store.find(store)
        @families = @store.blank? ? families_dropdown : ProductFamily.by_store(@store)
        @products = @store.blank? ? products_dropdown : @store.products.order(:product_code)
      else
        @families = families_dropdown
        @products = products_dropdown
      end
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "product_families" => @families, "product" => @products_dropdown }
      render json: @json_data
    end

    # Generate new inventory count from store & family
    def ic_generate_count
      store = params[:store]
      family = params[:family]
      type = params[:type].to_i
      count = nil
      count_item = nil
      code = ''

      if store != '0' && family != '0'
        if type == 1  # Initial
          stocks = ProductFamily.find(family).products.where(active: true) rescue nil
        else          # Regularization
          stocks = Stock.find_by_store_and_family(store, family) rescue nil
        end
        if !stocks.nil?
          if stocks.count <= 0
            # No Products
            code = '$no_products'
          else
            # Try save new inventory count
            inventory_count = InventoryCount.new
            inventory_count.count_no = ic_next_no(store)
            inventory_count.count_date = Time.now.to_date
            inventory_count.inventory_count_type_id = type
            inventory_count.store_id = store
            inventory_count.product_family_id = family
            inventory_count.organization_id = Store.find(store).organization_id rescue nil
            inventory_count.created_by = current_user.id if !current_user.nil?
            if inventory_count.save
              # Try to save new inventory count items
              stocks.each do |i|
                inventory_count_item = InventoryCountItem.new
                inventory_count_item.inventory_count_id = inventory_count.id
                inventory_count_item.quantity = 0
                if type == 1
                  inventory_count_item.product_id = i.id
                  inventory_count_item.initial = 0
                  inventory_count_item.current = 0
                else
                  inventory_count_item.product_id = i.product_id
                  inventory_count_item.initial = i.initial
                  inventory_count_item.current = i.current
                end
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
          end   # stocks.count <= 0
        else
          # Stocks not found
          code = '$err'
        end   # !stocks.nil?
      else
        # Store or Family 0
        code = '$err'
      end   # store != '0' && family != '0'
      if code == ''
        code = I18n.t("ag2_products.inventory_counts.generate_count_ok", var: inventory_count.full_no)
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

      inventory_count = InventoryCount.find(_order)
      if !inventory_count.nil?
        if inventory_count.approver_id.blank?
          # Can approve count
          _approver_id = current_user.id
          _approval_date = DateTime.now
          inventory_count.approver_id = _approver_id
          inventory_count.approval_date = _approval_date
          # Attempt approve
          if inventory_count.save
            # Success
            code = '$ok'
            # *** Update stocks & WAPs ***
            inventory_count.inventory_count_items.each do |i|
              #
              # Stock
              #
              stock = Stock.find_by_product_and_store(i.product_id, inventory_count.store_id)
              if !stock.nil?
                # Updates existing stock
                if inventory_count.inventory_count_type_id == 1      # Initial
                  stock.initial = i.quantity
                  stock.current = i.quantity + stock.receipts - stock.deliveries
                elsif inventory_count.inventory_count_type_id == 2   # Regularization
                  stock.current = i.quantity
                  stock.initial = i.quantity - stock.receipts + stock.deliveries
                end
              else
                # New stock
                stock = Stock.new
                stock.product_id = i.product_id
                stock.store_id = inventory_count.store_id
                stock.initial = i.quantity
                stock.current = i.quantity
                stock.minimum = 0
                stock.maximum = 0
                stock.created_by = current_user.id if !current_user.nil?
              end
              # Save stock
              if !stock.save
                # Can't save stock
                code = '$write'
                break
              end
              #
              # WAP
              #
              product_company_price = ProductCompanyPrice.find_by_product_and_company(i.product_id, inventory_count.store.company_id)
              if !product_company_price.nil?
                # Updates existing WAP by company
                if product_company_price.average_price != i.price
                  product_company_price.average_price = i.price
                end
              else
                # New WAP by company
                product_company_price = ProductCompanyPrice.new
                product_company_price.product_id = i.product_id
                product_company_price.company_id = inventory_count.store.company_id
                product_company_price.average_price = i.price
                product_company_price.created_by = current_user.id if !current_user.nil?
              end
              if product_company_price.average_price_changed?
                # Save WAP by company
                if !product_company_price.save
                  # Can't save WAP by company
                  code = '$write'
                  break
                else
                  # Product WAP
                  product = Product.find(i.product_id)
                  if !product.nil? && product.average_price <= 0
                    product.average_price = i.price
                    if !product.save
                      # Can't save Product WAP
                      code = '$write'
                      break
                    end
                  end
                end
              end
            end   # do |i|
          else
            # Can't save count
            code = '$write'
          end   # inventory_count.save
        else
          # This count is already approved
          code = '$warn'
        end
      else
        # Inventory count not found
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
      # Success
      if code == '' || code == '$ok'
        code = I18n.t("ag2_products.inventory_counts.approve_count_ok", var: inventory_count.full_no)
        send_approve_email(inventory_count)
      end

      @json_data = { "code" => code, "approver" => _approver, "approval_date" => _approval_date }
      render json: @json_data
    end

    # Update stocks & average price at view from product & store
    def ic_update_from_product_store
      product = params[:product]
      store = params[:store]
      tbl = params[:tbl]
      initial_stock = 0
      current_stock = 0
      company = nil
      product_company_price = nil
      average_price = 0
      if product != '0' && store != '0'
        stock = Stock.find_by_product_and_store(product, store)
        # Stocks
        initial_stock = stock.initial rescue 0
        current_stock = stock.current rescue 0
        # WAP
        average_price = Product.find(product).average_price rescue 0
        company = Store.find(store).company rescue nil
        if !company.blank?
          product_company_price = ProductCompanyPrice.find_by_product_and_company(product, company) rescue nil
          if !product_company_price.blank?
            average_price = product_company_price.average_price
          end
        end
      end
      # Format numbers
      initial_stock = number_with_precision(initial_stock.round(4), precision: 4)
      current_stock = number_with_precision(current_stock.round(4), precision: 4)
      average_price = number_with_precision(average_price.round(4), precision: 4)
      # Setup JSON hash
      @json_data = { "initial" => initial_stock.to_s, "stock" => current_stock.to_s,
                     "tbl" => tbl.to_s, "average_price" => average_price.to_s }
      render json: @json_data
    end

    # Update product & family select at view from store
    def ic_update_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @stores = @organization.blank? ? stores_dropdown : @organization.stores.order(:name)
        @families = @organization.blank? ? families_dropdown : @organization.product_families.order(:family_code)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @stores = stores_dropdown
        @families = families_dropdown
        @products = products_dropdown
      end
      # Products array
      @products_dropdown = products_array(@products)
      # Setup JSON
      @json_data = { "store" => @stores, "product" => @products_dropdown }
      render json: @json_data
    end

    def ic_products_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @products = products_dropdown
      end
      if params[:term]
        @products = @products.where("product_code LIKE ? OR main_description LIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
      end
      # Products paginate
      @products = @products.paginate(:page => params[:page], :per_page => per_page)
      @products_dropdown = products_array(@products)
      # Returns JSON
      render json: { :products => @products_dropdown,
                     :total => @products.count,
                     :links => { :self => @products.current_page , :next => @products.next_page} }
    end

    #
    # Default Methods
    #
    # GET /inventory_counts
    # GET /inventory_counts.json
    def index
      manage_filter_state
      no = params[:No]
      type = params[:Type]
      store = params[:Store]
      family = params[:Family]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @stores = stores_dropdown if @stores.nil?
      @families = families_dropdown if @families.nil?
      @types = InventoryCountType.order(:id) if @types.nil?

      # Arrays for search
      current_stores = @stores.blank? ? [0] : current_stores_for_index(@stores)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = InventoryCount.search do
        with :store_id, current_stores
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
        if !type.blank?
          with :inventory_count_type_id, type
        end
        order_by :sort_no, :desc
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
                     office_approver(@inventory_count, @inventory_count.store.office, current_user.id) ||
                     (current_user.has_role? :Approver)
      # If current user is not approver up to here, maybe it's a multioffice store...
      if !@is_approver
        @is_approver = multioffice_store_approver(@inventory_count, current_user.id)
      end

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
      @products_table = products_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @inventory_count }
      end
    end

    # GET /inventory_counts/1/edit
    def edit
      @breadcrumb = 'update'
      @inventory_count = InventoryCount.find(params[:id])
      @stores = stores_dropdown
      if @inventory_count.store.blank? || @inventory_count.inventory_count_type_id == 1
        @families = @inventory_count.organization.blank? ? families_dropdown : @inventory_count.organization.product_families.order(:family_code)
        @products = @inventory_count.organization.blank? ? products_dropdown : @inventory_count.organization.products.order(:product_code)
      else
        @families = ProductFamily.by_store(@inventory_count.store)
        @products = @inventory_count.store.products.order(:product_code)
      end
      #@products = @products.paginate(:page => params[:page], :per_page => per_page)
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

      items_changed = false
      if params[:inventory_count][:inventory_count_items_attributes]
        params[:inventory_count][:inventory_count_items_attributes].values.each do |new_item|
          current_item = InventoryCountItem.find(new_item[:id]) rescue nil
          if ((current_item.nil?) || (new_item[:_destroy] != "false") ||
             ((current_item.product_id.to_i != new_item[:product_id].to_i) ||
              (current_item.quantity.to_f != new_item[:quantity].to_f)))
            items_changed = true
            break
          end
        end
      end
      master_changed = false
      if ((params[:inventory_count][:count_date].to_date != @inventory_count.count_date) ||
          (params[:inventory_count][:count_no].to_s != @inventory_count.count_no) ||
          (params[:inventory_count][:remarks].to_s != @inventory_count.remarks) ||
          (params[:inventory_count][:inventory_count_type_id].to_i != @inventory_count.inventory_count_type_id.to_i) ||
          (params[:inventory_count][:store_id].to_i != @inventory_count.store_id.to_i) ||
          (params[:inventory_count][:product_family_id].to_i != @inventory_count.product_family_id.to_i) ||
          (params[:inventory_count][:organization_id].to_i != @inventory_count.organization_id.to_i))
        master_changed = true
      end
      #@inventory_count.inventory_count_items.assign_attributes(params[:inventory_count][:inventory_count_items_attributes])

      respond_to do |format|
        if master_changed || items_changed
          @inventory_count.updated_by = current_user.id if !current_user.nil?
          if @inventory_count.update_attributes(params[:inventory_count])
            format.html { redirect_to @inventory_count,
                          notice: (crud_notice('updated', @inventory_count) + "#{undo_link(@inventory_count)}").html_safe }
            format.json { head :no_content }
          else
            @stores = stores_dropdown
            if @inventory_count.store.blank? || @inventory_count.inventory_count_type_id == 1
              @families = @inventory_count.organization.blank? ? families_dropdown : @inventory_count.organization.product_families.order(:family_code)
              @products = @inventory_count.organization.blank? ? products_dropdown : @inventory_count.organization.products.order(:product_code)
            else
              @families = ProductFamily.by_store(@inventory_count.store)
              @products = @inventory_count.store.products.order(:product_code)
            end
            format.html { render action: "edit" }
            format.json { render json: @inventory_count.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @inventory_count }
          format.json { head :no_content }
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

    # Inventory count form (report)
    def inventory_count_form
      # Search inventory count & items
      @inventory_count = InventoryCount.find(params[:id])
      @items = @inventory_count.inventory_count_items

      title = t("activerecord.models.inventory_count.one")

      respond_to do |format|
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}_#{@inventory_count.full_no}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Inventory counts report
    def inventory_counts_report
      manage_filter_state
      no = params[:No]
      type = params[:Type]
      store = params[:Store]
      family = params[:Family]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = InventoryCount.search do
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
        if !type.blank?
          with :inventory_count_type_id, type
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => InventoryCount.count
      end

      @inventory_counts_report = @search.results

      if !@inventory_counts_report.blank?
        title = t("activerecord.models.inventory_count.few")
        @to = formatted_date(@inventory_counts_report.first.created_at)
        @from = formatted_date(@inventory_counts_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Order is approved
    def cannot_edit(_count)
      !session[:is_administrator] && !_count.approver_id.blank?
    end

    def current_stores_for_index(_stores)
      _current_stores = []
      _stores.each do |i|
        _current_stores = _current_stores << i.id
      end
      _current_stores
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      InventoryCount.where('count_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.count_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def stores_dropdown
      _array = []
      _stores = nil
      _store_offices = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _stores = Store.where(office_id: session[:office].to_i)
        _store_offices = StoreOffice.where("office_id = ?", session[:office].to_i)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _stores = Store.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
          _store_offices = StoreOffice.where("office_id IN (?)", _offices)
        else
          _stores = Store.where(company_id: session[:company].to_i)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _stores = Store.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
          _store_offices = StoreOffice.where("office_id IN (?)", _offices)
        else
          _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i) : Store.order
        end
        #_stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i) : Store.order
      end

      # Returning founded stores
      ret_array(_array, _stores, 'id')
      ret_array(_array, _store_offices, 'store_id')
      _stores = Store.where(id: _array).order(:name)
=begin
      if session[:office] != '0'
        _stores = Store.where(office_id: session[:office].to_i).order(:name)
      elsif session[:company] != '0'
        _stores = Store.where(company_id: session[:company].to_i).order(:name)
      else
        _stores = session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
      end
=end
    end

    def families_dropdown
      session[:organization] != '0' ? ProductFamily.where(organization_id: session[:organization].to_i).order(:family_code) : ProductFamily.order(:family_code)
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end

    def families_array(_families)
      _array = []
      _families.each do |i|
        _array = _array << [i.id, i.family_code, i.name[0,40]]
      end
      _array
    end

    def products_array(_products)
      _array = []
      _products.each do |i|
        #_array = _array << [i.id, i.full_code, i.main_description[0,40], '*' + i.manufacturer_p_code]
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

    def send_approve_email(_inventory_count)
      code = '$ok'
      from = nil
      to = nil

      from = !current_user.nil? ? User.find(current_user.id).email : User.find(_inventory_count.approver_id).email
      to = !_inventory_count.created_by.blank? ? User.find(_inventory_count.created_by).email : nil

      if from.blank? || to.blank?
        code = "$err"
      else
        # Send e-mail
        Notifier.send_inventory_count_approval(_inventory_count, from, to).deliver
      end

      code
    end

    # Check if store is multioffice, and setup approver based on that
    def multioffice_store_approver(ivar, current_user_id)
      is_multioffice_approver = false
      table = ivar.class.table_name
      store_offices = StoreOffice.where(store_id: ivar.store_id)
      if !store_offices.blank?
        store_offices.each do |o|
          notifications = o.office.office_notifications.joins(:notification).where('notifications.table = ? AND office_notifications.role = ? AND office_notifications.user_id = ?', table, 1, current_user_id) rescue nil
          if !notifications.blank?
            is_multioffice_approver = true
            break
          end
        end
      end
      is_multioffice_approver
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
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
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
end
