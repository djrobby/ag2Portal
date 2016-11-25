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
      @commercial_billings = @search.results
      authorize! :index, @commercial_billings

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @commercial_billings }
        format.js
      end
    end

    # GET /commercial_billings/1
    # GET /commercial_billings/1.json
    def show
      @breadcrumb = 'read'
      @commercial_billing = Invoice.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @commercial_billing }
      end
    end

    # GET /commercial_billings/new
    # GET /commercial_billings/new.json
    def new
      @breadcrumb = 'create'
      @commercial_billing = Invoice.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @commercial_billing }
      end
    end

    # GET /commercial_billings/1/edit
    def edit
      @breadcrumb = 'update'
      @commercial_billing = Invoice.find(params[:id])
    end

    # POST /commercial_billings
    # POST /commercial_billings.json
    def create
      @breadcrumb = 'create'
      @commercial_billing = Invoice.new(params[:commercial_billing])

      respond_to do |format|
        if @commercial_billing.save
          format.html { redirect_to @commercial_billing, notice: crud_notice('created', @commercial_billing) }
          format.json { render json: @commercial_billing, status: :created, location: @commercial_billing }
        else
          format.html { render action: "new" }
          format.json { render json: @commercial_billing.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /commercial_billings/1
    # PUT /commercial_billings/1.json
    def update
      @breadcrumb = 'update'
      @commercial_billing = Invoice.find(params[:id])

      respond_to do |format|
        if @commercial_billing.update_attributes(params[:commercial_billing])
          format.html { redirect_to @commercial_billing,
                        notice: (crud_notice('updated', @commercial_billing) + "#{undo_link(@commercial_billing)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @commercial_billing.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /commercial_billings/1
    # DELETE /commercial_billings/1.json
    def destroy
      @commercial_billing = Invoice.find(params[:id])

      respond_to do |format|
        if @commercial_billing.destroy
          format.html { redirect_to commercial_billings_url,
                      notice: (crud_notice('destroyed', @commercial_billing) + "#{undo_link(@commercial_billing)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to commercial_billings_url, alert: "#{@commercial_billing.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @commercial_billing.errors, status: :unprocessable_entity }
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
      if session[:office_id] != '0'
        Subscriber.belongs_to_office(session[:office_id].to_i)
      else
        Subscriber.by_code
      end
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
