require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CommercialBillingsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    #load_and_authorize_resource (error: model class does not exist)
    # Must authorize manually for every action in this controller

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
      @clients = clients_dropdown if @clients.nil?
      @subscribers = subscribers_dropdown if @subscribers.nil?
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @billers = billers_dropdown if @billers.nil?
      @periods = billing_periods_dropdown if @periods.nil?

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
          with :client_id, client
        end
        if !subscriber.blank?
          with :subscriber_id, subscriber
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
      @sale_offers = sale_offers_dropdown
      @projects = projects_dropdown
      @charge_accounts = projects_charge_accounts(@projects)
      @clients = clients_dropdown
      @payment_methods = payment_methods_dropdown
      @products = products_dropdown
      @offer_items = []

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice }
      end
    end

    # GET /commercial_billings/1/edit
    def edit
      @breadcrumb = 'update'
      @invoice = Invoice.find(params[:id])
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
    end

    # POST /commercial_billings
    # POST /commercial_billings.json
    def create
      @breadcrumb = 'create'
      @invoice = Invoice.new(params[:invoice])
      @invoice.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        #
        # Must create associated bill before
        #
        # bill_create()
        # Go on
        if @invoice.save
          format.html { redirect_to @invoice, notice: crud_notice('created', @invoice) }
          format.json { render json: @invoice, status: :created, location: @invoice }
        else
          @sale_offers = sale_offers_dropdown
          @projects = projects_dropdown
          @charge_accounts = projects_charge_accounts(@projects)
          @clients = clients_dropdown
          @payment_methods = payment_methods_dropdown
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
      if ((params[:invoice][:organization_id].to_i != @supplier_invoice.organization_id.to_i) ||
          (params[:invoice][:invoice_no].to_s != @supplier_invoice.invoice_no) ||
          (params[:invoice][:invoice_date].to_date != @supplier_invoice.invoice_date) ||
          #(params[:invoice][:client_id].to_i != @supplier_invoice.client_id.to_i) ||
          (params[:invoice][:sale_offer_id].to_i != @supplier_invoice.sale_offer_id.to_i) ||
          (params[:invoice][:charge_account_id].to_i != @supplier_invoice.charge_account_id.to_i) ||
          (params[:invoice][:payment_method_id].to_i != @supplier_invoice.payment_method_id.to_i) ||
          (params[:invoice][:discount_pct].to_f != @supplier_invoice.discount_pct.to_f) ||
          (params[:invoice][:remarks].to_s != @supplier_invoice.remarks))
        master_changed = true
      end

      respond_to do |format|
        if master_changed || items_changed
          @invoice.updated_by = current_user.id if !current_user.nil?
          if @invoice.update_attributes(params[:invoice])
            #
            # Must update associated bill after
            #
            # bill_update()
            # Go on
            format.html { redirect_to @invoice,
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
          format.html { redirect_to @invoice }
          format.json { head :no_content }
        end
      end
    end

    # DELETE /commercial_billings/1
    # DELETE /commercial_billings/1.json
    def destroy
      @invoice = Invoice.find(params[:id])

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
      _projects.each do |i|
        _ret = ChargeAccount.incomes(i.id)
        ret_array(_array, _ret, 'id')
      end

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

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.incomes.where('project_id = ? OR (project_id IS NULL AND charge_accounts.organization_id = ?)', _project, _project.organization_id)
    end

    def clients_dropdown
      session[:organization] != '0' ? Client.belongs_to_organization(session[:organization].to_i) : Client.by_code
    end

    def subscribers_dropdown
      session[:office_id] != '0' ? Subscriber.belongs_to_office(session[:office_id].to_i) : Subscriber.by_code
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

    # Returns _array from _ret table/model filled with _id attribute
    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
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
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
    end
  end
end
