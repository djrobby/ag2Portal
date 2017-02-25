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
                                               :so_update_offer_select_from_client,
                                               :so_update_selects_from_offer,
                                               :so_update_selects_from_project,
                                               :so_format_number,
                                               :so_format_number_4,
                                               :so_item_totals,
                                               :so_update_description_prices_from_product,
                                               :so_update_product_select_from_offer_item,
                                               :so_update_amount_from_price_or_quantity,
                                               :so_item_balance_check,
                                               :so_item_totals,
                                               :so_generate_invoice,
                                               :so_current_balance,
                                               :send_invoice_form,
                                               :invoice_form,
                                               :bill_create, :bill_update]
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
          fulltext client
        end
        if !project.blank?
          with :project_id, project
        end
        if !status.blank?
          with :sale_offer_status_id, status
        end
        if !request.blank?
          with :contracting_request_id, request
        end
        order_by :sort_no, :asc
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
      @charge_accounts = projects_charge_accounts(@projects)
      @clients = clients_dropdown
      @contracting_requests = contracting_requests_dropdown
      @payment_methods = payment_methods_dropdown
      @work_orders = work_orders_dropdown
      @stores = stores_dropdown
      @status = sale_offer_statuses_dropdown if @status.nil?
      @products = products_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer }
      end
    end

    # GET /sale_offers/1/edit
    def edit
      @breadcrumb = 'update'
      @sale_offer = SaleOffer.find(params[:id])
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

      respond_to do |format|
        if @sale_offer.update_attributes(params[:sale_offer])
          format.html { redirect_to @sale_offer,
                        notice: (crud_notice('updated', @sale_offer) + "#{undo_link(@sale_offer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
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
      _projects = Project.where(id: _array).order(:project_code)
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

    # Contracting requests belonging to projects
    def projects_contracting_requests(_projects)
      ContractingRequest.where(project_id: _projects).by_no
    end

    def sale_offer_statuses_dropdown
      SaleOfferStatus.all
    end

    def stores_dropdown
      session[:organization] != '0' ? Store.where(organization_id: session[:organization].to_i).order(:name) : Store.order(:name)
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def contracting_requests_dropdown
      session[:organization] != '0' ? ContractingRequest.belongs_to_organization(session[:organization].to_i) : ContractingRequest.by_no
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
