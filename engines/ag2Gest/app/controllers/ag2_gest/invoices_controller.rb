require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoicesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:iv_remove_filters,
                                               :iv_restore_filters]
    # Helper methods for
    # => returns client code & full name
    helper_method :client_name
    # => index filters
    helper_method :iv_remove_filters, :iv_restore_filters

    # GET /invoices
    # GET /invoices.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      client = params[:Client]
      subscriber = params[:Subscriber]
      street_name = params[:StreetName]
      status = params[:Status]
      type = params[:Type]
      operation = params[:Operation]
      biller = params[:Biller]
      period = params[:Period]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      # @client = !client.blank? ? Client.find(client).to_label : " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @biller = !biller.blank? ? Company.find(biller).full_name : " "
      @period = !period.blank? ? BillingPeriod.find(period).to_label : " "
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no
      client = !client.blank? ? inverse_client_search(client) : client
      subscriber = !subscriber.blank? ? inverse_subscriber_search(subscriber) : subscriber
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      @search = Invoice.search do
        with :project_id, current_projects
        fulltext params[:search]
        if !no.blank?
          if no.class == Array
            with :invoice_no, no
          else
            with(:invoice_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !client.blank?
          if client.class == Array
            with :client_code_name_fiscal, client
          else
            with(:client_code_name_fiscal).starting_with(client)
          end
        end
        # if !client.blank?
        #   with :client_id, client
        # end
        if !subscriber.blank?
          if subscriber.class == Array
            with :subscriber_code_name_fiscal, subscriber
          else
            with(:subscriber_code_name_fiscal).starting_with(subscriber)
          end
        end
        if !street_name.blank?
          if street_name.class == Array
            with :supply_address, street_name
          else
            with(:supply_address).starting_with(street_name)
          end
        end
        # if !subscriber.blank?
        #   fulltext subscriber
        # end
        # if !subscriber.blank?
        #   with :subscriber_id, subscriber
        # end
        if !type.blank?
          with :invoice_type_id, type
        end
        if !status.blank?
          with :invoice_status_id, status
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
        if !from.blank?
          any_of do
            with(:invoice_date).greater_than(from)
            with :invoice_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:invoice_date).less_than(to)
            with :invoice_date, to
          end
        end
        data_accessor_for(Invoice).include = [:invoice_type, :invoice_status, :invoice_operation, {bill: :client}, :biller, {invoice_items: :tax_type}]
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @invoices = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoices }
        format.js
      end
    end

    # GET /invoices/1
    # GET /invoices/1.json
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

    # GET /invoices/new
    # GET /invoices/new.json
    def new
      @invoice = Invoice.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice }
      end
    end

    # GET /invoices/1/edit
    def edit
      @invoice = Invoice.find(params[:id])
    end

    # POST /invoices
    # POST /invoices.json
    def create
      @invoice = Invoice.new(params[:invoice])

      respond_to do |format|
        if @invoice.save
          format.html { redirect_to @invoice, notice: t('activerecord.attributes.invoice.create') }
          format.json { render json: @invoice, status: :created, location: @invoice }
        else
          format.html { render action: "new" }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /invoices/1
    # PUT /invoices/1.json
    def update
      @invoice = Invoice.find(params[:id])

      respond_to do |format|
        if @invoice.update_attributes(params[:invoice])
          format.html { redirect_to @invoice, notice: t('activerecord.attributes.invoice.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /invoices/1
    # DELETE /invoices/1.json
    def destroy
      @invoice = Invoice.find(params[:id])
      @invoice.destroy

      respond_to do |format|
        format.html { redirect_to invoices_url }
        format.json { head :no_content }
      end
    end

     # invoice report
    def invoice_view_report
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
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = Invoice.search do
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
        if !from.blank?
          any_of do
            with(:invoice_date).greater_than(from)
            with :invoice_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:invoice_date).less_than(to)
            with :invoice_date, to
          end
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Invoice.count
      end
      @invoice_report = @search.results

      if !@invoice_report.blank?
        title = t("activerecord.models.invoice.few")
        @from = formatted_date(@invoice_report.first.created_at)
        @to = formatted_date(@invoice_report.last.created_at)
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

    def setup_no(no)
      no = no[0] != '%' ? '%' + no : no
      no = no[no.length-1] != '%' ? no + '%' : no
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Invoice.where('invoice_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.invoice_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def inverse_client_search(client)
      _numbers = []
      no = setup_no(client)
      w = "(client_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      Client.where(w).first(1000).each do |i|
        _numbers = _numbers << i.full_name_or_company_code_fiscal
      end
      _numbers = _numbers.blank? ? client : _numbers
    end

    def inverse_subscriber_search(subscriber)
      _numbers = []
      no = setup_no(subscriber)
      w = "(subscriber_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      Subscriber.where(w).first(1000).each do |i|
        _numbers = _numbers << i.code_full_name_or_company_fiscal
      end
      _numbers = _numbers.blank? ? subscriber : _numbers
    end

    def inverse_street_name_search(supply_address)
      _numbers = []
      no = setup_no(supply_address)
      SubscriberSupplyAddress.where('supply_address LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.supply_address
      end
      _numbers = _numbers.blank? ? supply_address : _numbers
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

    def this_current_projects_ids
      projects_dropdown.pluck(:id)
    end

    def clients_dropdown
      if session[:organization] != '0'
        Client.belongs_to_organization(session[:organization].to_i)
      else
        Client.order("created_at DESC")
      end
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
      InvoiceType.all
    end

    def invoice_operations_dropdown
      InvoiceOperation.all
    end

    def billers_dropdown
      session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
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
      # street_name
      if params[:StreetName]
        session[:StreetName] = params[:StreetName]
      elsif session[:StreetName]
        params[:StreetName] = session[:StreetName]
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
      # From
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end
      # To
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end
    end

    def iv_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Project] = ""
      params[:Client] = ""
      params[:Subscriber] = ""
      params[:StreetName] = ""
      params[:Status] = ""
      params[:Type] = ""
      params[:Operation] = ""
      params[:Biller] = ""
      params[:Period] = ""
      params[:From] = ""
      params[:To] = ""
      return " "
    end

    def iv_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Client] = session[:Client]
      params[:Subscriber] = session[:Subscriber]
      params[:StreetName] = session[:StreetName]
      params[:Status] = session[:Status]
      params[:Type] = session[:Type]
      params[:Operation] = session[:Operation]
      params[:Biller] = session[:Biller]
      params[:Period] = session[:Period]
      params[:From] = session[:From]
      params[:To] = session[:To]
    end
  end
end
