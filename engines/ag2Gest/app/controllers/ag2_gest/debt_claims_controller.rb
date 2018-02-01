require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:dc_remove_filters,
                                               :dc_restore_filters,
                                               :dcb_remove_filters,
                                               :dcb_restore_filters,
                                               :dc_generate_no,
                                               :generate,
                                               :bills]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit
    # => returns client code & full name
    helper_method :client_name, :biller_name
    # => index filters
    helper_method :dc_remove_filters, :dc_restore_filters
    # => bills filters
    helper_method :dcb_remove_filters, :dcb_restore_filters

    # Update claim number at view (generate_code_btn)
    def dc_generate_no
      office = params[:office]

      # Builds no, if possible
      code = office == '$' ? '$err' : dc_next_no(office)
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Generate new debt claim
    def generate
      # required params
      office = params[:debt_claim][:office]
      payday_limit = params[:debt_claim][:payday_limit]   # YYYYMMDD
      # optional params
      projects = params[:debt_claim][:projects]
      periods = params[:debt_claim][:periods]
      reading_routes = params[:debt_claim][:reading_routes]
      clients = params[:debt_claim][:clients]
      subscribers = params[:debt_claim][:subscribers]
      invoice_types = params[:debt_claim][:invoice_types]
      # numeric params
      pending_amount = BigDecimal(params[:debt_claim][:pending_amount]) rescue 0.0
      pending_invoices = Integer(params[:debt_claim][:pending_amount]) rescue 0
      if pending_amount < 0 || pending_invoices < 0
        redirect_to debt_claims_path, alert: I18n.t("ag2_gest.debt_claims.generate_error_numeric") and return
      end

      # Formats input params data
      payday_limit = (payday_limit[0..3] + '-' + payday_limit[4..5] + '-' + payday_limit[6..7]).to_date
      projects = projects.split(",") if !projects.blank?
      periods = periods.split(",") if !periods.blank?
      reading_routes = reading_routes.split(",") if !reading_routes.blank?
      clients = clients.split(",") if !clients.blank?
      subscribers = subscribers.split(",") if !subscribers.blank?
      invoice_types = invoice_types.split(",") if !invoice_types.blank?

      # Builds WHERE
      w = ''
      w = "invoice_current_debts.office_id = #{office}" if !office.blank?
      if !payday_limit.blank?
        w += " AND " if w != ''
        w += "payday_limit < #{payday_limit}"
      end
      if !projects.blank?
        w += " AND " if w != ''
        w += "project_id IN (#{projects})"
      end
      if !periods.blank?
        w += " AND " if w != ''
        w += "period_id IN (#{periods})"
      end
      if !reading_routes.blank?
        w += " AND " if w != ''
        w += "subscribers.reading_route_id IN (#{reading_routes})"
      end
      if !clients.blank?
        w += " AND " if w != ''
        w += "client_id IN (#{clients})"
      end
      if !subscribers.blank?
        w += " AND " if w != ''
        w += "subscriber_id IN (#{subscribers})"
      end
      if !invoice_types.blank?
        w += " AND " if w != ''
        w += "invoice_type_id IN (#{invoice_types})"
      end

      # Retrieve current outstanding invoices
      invoices = InvoiceCurrentDebt.g_where_and_unclaimed(w)
      redirect_to debt_claims_path, alert: I18n.t("ag2_gest.debt_claims.generate_error_no_data") and return if invoices.size < 1

      # Group & total: Retrieve clients with right pending_amount or pending_invoices
      g = invoices.group(:client_id)
                  .select('client_id, SUM(debt) AS pending_amount, COUNT(invoice_id) AS pending_invoices')
                  .having('pending_amount > ? OR pending_invoices > ?', pending_amount, pending_invoices)
      if !g.blank?
        # Filter invoice records
        c = g.pluck(:client_id)
        invoices = invoices.where(client_id: c)
      end

      # Set project if it's unique
      project = nil
      project = projects[0] if projects.count == 1

      # Claim No.
      claim_no = dc_next_no(office)

      # Begin the transaction
      begin
        ActiveRecord::Base.transaction do
          # Create debt claim
          claim = DebtClaim.create(office_id: office, project_id: project,
                                   claim_no: claim_no, closed_at: nil,
                                   debt_claim_phase_id: DebtClaimPhase::FIRST_CLAIM)
          # Loop thru invoices and create items
          invoices.each do |i|
            DebtClaimItem.create(debt_claim_id: claim.id, bill_id: i.bill_id,
                                 invoice_id: i.invoice_id, debt_claim_status_id: DebtClaimStatus::INITIATED,
                                 debt: i.debt, payday_limit: Time.now.to_date + 1.month)
          end # invoices.each

          redirect_to debt_claim_path(claim), notice: I18n.t("ag2_gest.debt_claims.generate.notice")
        end # ActiveRecord::Base.transaction
      rescue ActiveRecord::RecordInvalid
        redirect_to debt_claims_path, alert: I18n.t("ag2_gest.debt_claims.generate.alert") and return
      end # begin
    end

    # Show reclaimable bills
    def bills
      dcb_manage_filter_state
      no = params[:NoB]
      project = params[:ProjectB]
      client = params[:ClientB]
      subscriber = params[:SubscriberB]
      street_name = params[:StreetNameB]
      type = params[:TypeB]
      operation = params[:OperationB]
      biller = params[:BillerB]
      period = params[:PeriodB]
      from = params[:FromB]
      to = params[:ToB]
      # OCO
      init_oco if !session[:organization]

      # Initialize select_tags
      @project = !project.blank? ? Project.find(project).full_name : " "
      @biller = !biller.blank? ? Company.find(biller).full_name : " "
      @period = !period.blank? ? BillingPeriod.find(period).to_label : " "
      @types = InvoiceType.all if @types.nil?
      @operations = InvoiceOperation.all if @operations.nil?

      # Formats input params data
      from = (from[0..3] + '-' + from[4..5] + '-' + from[6..7]).to_date rescue nil
      to = (to[0..3] + '-' + to[4..5] + '-' + to[6..7]).to_date rescue nil
      no = !no.blank? && (no.first != '%' && no.last != '%') ? no + '%' : no

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? nil : current_projects_for_index(@projects).join(", ")
      # If inverse no search is required
      client = inverse_client_search(client) if !client.blank?
      subscriber = inverse_subscriber_search(subscriber) if !subscriber.blank?
      street_name = inverse_street_name_search(street_name) if !street_name.blank?
      client = client.class == Array ? client.join(", ") : ''
      subscriber = subscriber.class == Array ? subscriber.join(", ") : ''
      street_name = street_name.class == Array ? street_name.join(", ") : ''

      # Builds WHERE
      w = ''
      w = "invoice_current_debts.project_id IN (#{current_projects})" if !current_projects.blank?
      if !no.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.invoice_no LIKE #{no}"
      end
      if !project.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.project_id = #{project}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.client_id IN (#{client})"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.subscriber_id IN (#{subscriber})"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.subscriber_id IN (#{street_name})"
      end
      if !type.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.invoice_type_id = #{type}"
      end
      if !operation.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.invoice_operation_id = #{operation}"
      end
      if !biller.blank?
        w += " AND " if w != ''
        w += "invoices.biller_id = #{biller}"
      end
      if !period.blank?
        w += " AND " if w != ''
        w += "invoices.billing_period_id = #{period}"
      end
      if !from.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.payday_limit >= #{from}"
      end
      if !to.blank?
        w += " AND " if w != ''
        w += "invoice_current_debts.payday_limit <= #{to}"
      end

      @bills = InvoiceCurrentDebt.g_where_and_unclaimed(w).paginate(:page => params[:page] || 1, :per_page => per_page || 10)
      bill_totals = @bills.select('COUNT(*) DEBT_COUNT, SUM(invoice_current_debts.debt) DEBT_TOTAL').first
      @bill_totals_count = bill_totals.DEBT_COUNT || 0
      @bill_totals_total = bill_totals.DEBT_TOTAL || 0

      respond_to do |format|
        format.html # bills.html.erb
        format.json { render json: @debt_claims }
        format.js
      end
    end

    #
    # Default Methods
    #
    # GET /debt_claims
    # GET /debt_claims.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      client = params[:Client]
      status = params[:Status]
      phase = params[:Phase]
      # OCO
      init_oco if !session[:organization]

      # Initialize select_tags
      @client = !client.blank? ? Client.find(client).to_label : " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @status = debt_claim_statuses_dropdown if @status.nil?
      @phase = debt_claim_phases_dropdown if @phase.nil?

      # Initialize modal generate tags
      @offices = offices_dropdown if @offices.nil?
      @invoice_types = invoice_types_dropdown if @invoice_types.nil?
      @period = " "
      @reading_route = " "
      @subscriber = " "

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      if !client.blank? && !status.blank?
        items = DebtClaimItem.belongs_to_client_and_has_status(client, status)
      elsif !client.blank? && status.blank?
        items = DebtClaimItem.belongs_to_client(client)
      elsif client.blank? && !status.blank?
        items = DebtClaimItem.has_status(status)
      else
        items = DebtClaimItem.grouped_by_debt_claim
      end
      current_items = items.blank? ? [0] : current_items_for_index(items)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = DebtClaim.search do
        with :id, current_items
        with :project_id, current_projects
        fulltext params[:search]
        if !no.blank?
          if no.class == Array
            with :claim_no, no
          else
            with(:claim_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !phase.blank?
          with :debt_claim_phase_id, phase
        end
        data_accessor_for(DebtClaim).include = [:debt_claim_phase, :project, {debt_claim_items: :debt_claim_status}, {debt_claim_items: {bill: :client}}]
        order_by :sort_no, :desc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @debt_claims = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claims }
        format.js
      end
    end

    # GET /debt_claims/1
    # GET /debt_claims/1.json
    def show
      @breadcrumb = 'read'
      @debt_claim = DebtClaim.find(params[:id])
      @items = @debt_claim.debt_claim_items.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/new
    # GET /debt_claims/new.json
    def new
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/1/edit
    def edit
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
    end

    # POST /debt_claims
    # POST /debt_claims.json
    def create
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new(params[:debt_claim])
      @debt_claim.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.save
          format.html { redirect_to @debt_claim, notice: crud_notice('created', @debt_claim) }
          format.json { render json: @debt_claim, status: :created, location: @debt_claim }
        else
          format.html { render action: "new" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /debt_claims/1
    # PUT /debt_claims/1.json
    def update
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
      @debt_claim.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.update_attributes(params[:debt_claim])
          format.html { redirect_to @debt_claim,
                        notice: (crud_notice('updated', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /debt_claims/1
    # DELETE /debt_claims/1.json
    def destroy
      @debt_claim = DebtClaim.find(params[:id])

      respond_to do |format|
        if @debt_claim.destroy
          format.html { redirect_to debt_claims_url,
                      notice: (crud_notice('destroyed', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to debt_claims_url, alert: "#{@debt_claim.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Claim is closed
    def cannot_edit(_claim)
      !session[:is_administrator] && _claim.debt_claim_phase_id == DebtClaimPhase::CLOSED
    end

    def client_name(_bill)
      _name = _bill.CLIENT_CODE + ' ' + _bill.CLIENT_NAME rescue nil
      _name.blank? ? '' : _name[0,40]
    end

    def biller_name(_bill)
      _name = _bill.BILLER rescue nil
      _name.blank? ? '' : _name[0,40]
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def current_items_for_index(_items)
      _items.pluck(:debt_claim_id)
    end

    def setup_no(no)
      no = no[0] != '%' ? '%' + no : no
      no = no[no.length-1] != '%' ? no + '%' : no
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      InvoiceCurrentDebt.where('invoice_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.invoice_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def inverse_client_search(client)
      _numbers = []
      no = setup_no(client)
      w = "(client_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      _numbers = Client.where(w).order(:id).limit(1000).pluck(:id)
      _numbers.blank? ? nil : _numbers
    end

    def inverse_subscriber_search(subscriber)
      _numbers = []
      no = setup_no(subscriber)
      w = "(subscriber_code LIKE '#{no}' OR last_name LIKE '#{no}' OR first_name LIKE '#{no}' OR company LIKE '#{no}' OR fiscal_id LIKE '#{no}')"
      _numbers = Subscriber.where(w).order(:id).limit(1000).pluck(:id)
      _numbers.blank? ? nil : _numbers
    end

    def inverse_street_name_search(supply_address)
      _numbers = []
      no = setup_no(supply_address)
      w = "supply_address LIKE '#{no}'"
      _numbers = SubscriberSupplyAddress.where(w).order(:subscriber_id).limit(1000).pluck(:subscriber_id)
      _numbers.blank? ? nil : _numbers
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
      _projects = Project.where(id: _array).by_code
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def debt_claim_phases_dropdown
      DebtClaimPhase.all
    end

    def debt_claim_statuses_dropdown
      DebtClaimStatus.all
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

    def offices_dropdown
      if session[:office] != '0'
        Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        Office.where(company_id: session[:company].to_i).order(:name)
      elsif session[:organization] != '0'
        Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name)
      else
        Office.order(:name)
      end
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
      # phase
      if params[:Phase]
        session[:Phase] = params[:Phase]
      elsif session[:Phase]
        params[:Phase] = session[:Phase]
      end
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
    end

    def dc_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Project] = ""
      params[:Client] = ""
      params[:Phase] = ""
      params[:Status] = ""
      return " "
    end

    def dc_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Client] = session[:Client]
      params[:Phase] = session[:Phase]
      params[:Status] = session[:Status]
    end

    # Keeps filter state
    def dcb_manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # no
      if params[:NoB]
        session[:NoB] = params[:NoB]
      elsif session[:NoB]
        params[:NoB] = session[:NoB]
      end
      # project
      if params[:ProjectB]
        session[:ProjectB] = params[:ProjectB]
      elsif session[:ProjectB]
        params[:ProjectB] = session[:ProjectB]
      end
      # client
      if params[:ClientB]
        session[:ClientB] = params[:ClientB]
      elsif session[:ClientB]
        params[:ClientB] = session[:ClientB]
      end
      # subscriber
      if params[:SubscriberB]
        session[:SubscriberB] = params[:SubscriberB]
      elsif session[:SubscriberB]
        params[:SubscriberB] = session[:SubscriberB]
      end
      # street_name
      if params[:StreetNameB]
        session[:StreetNameB] = params[:StreetNameB]
      elsif session[:StreetNameB]
        params[:StreetNameB] = session[:StreetNameB]
      end
      # status
      if params[:StatusB]
        session[:StatusB] = params[:StatusB]
      elsif session[:StatusB]
        params[:StatusB] = session[:StatusB]
      end
      # type
      if params[:TypeB]
        session[:TypeB] = params[:TypeB]
      elsif session[:TypeB]
        params[:TypeB] = session[:TypeB]
      end
      # operation
      if params[:OperationB]
        session[:OperationB] = params[:OperationB]
      elsif session[:OperationB]
        params[:OperationB] = session[:OperationB]
      end
      # biller
      if params[:BillerB]
        session[:BillerB] = params[:BillerB]
      elsif session[:BillerB]
        params[:BillerB] = session[:BillerB]
      end
      # period
      if params[:PeriodB]
        session[:PeriodB] = params[:PeriodB]
      elsif session[:PeriodB]
        params[:PeriodB] = session[:PeriodB]
      end
      # From
      if params[:FromB]
        session[:FromB] = params[:FromB]
      elsif session[:FromB]
        params[:FromB] = session[:FromB]
      end
      # To
      if params[:ToB]
        session[:ToB] = params[:ToB]
      elsif session[:ToB]
        params[:ToB] = session[:ToB]
      end
    end

    def dcb_remove_filters
      params[:search] = ""
      params[:NoB] = ""
      params[:ProjectB] = ""
      params[:ClientB] = ""
      params[:SubscriberB] = ""
      params[:StreetNameB] = ""
      params[:StatusB] = ""
      params[:TypeB] = ""
      params[:OperationB] = ""
      params[:BillerB] = ""
      params[:PeriodB] = ""
      params[:FromB] = ""
      params[:ToB] = ""
      return " "
    end

    def dcb_restore_filters
      params[:search] = session[:search]
      params[:NoB] = session[:NoB]
      params[:ProjectB] = session[:ProjectB]
      params[:ClientB] = session[:ClientB]
      params[:SubscriberB] = session[:SubscriberB]
      params[:StreetNameB] = session[:StreetNameB]
      params[:StatusB] = session[:StatusB]
      params[:TypeB] = session[:TypeB]
      params[:OperationB] = session[:OperationB]
      params[:BillerB] = session[:BillerB]
      params[:PeriodB] = session[:PeriodB]
      params[:FromB] = session[:FromB]
      params[:ToB] = session[:ToB]
    end
  end
end
