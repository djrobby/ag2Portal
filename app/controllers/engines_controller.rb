class EnginesController < ApplicationController
  before_filter :set_params, :except => [:reset_filters]

  #
  # Resetting module (engine) session variables for filters
  #
  def reset_filters
    # Shared
    session[:search] = nil
    session[:letter] = nil
    session[:sort] = nil
    session[:direction] = nil
    session[:ifilter] = nil
    session[:active_tab] = nil
    session[:From] = nil
    session[:To] = nil
    session[:Type] = nil
    session[:No] = nil
    session[:Project] = nil
    session[:Order] = nil
    session[:Account] = nil
    session[:Products] = nil
    session[:Suppliers] = nil
    session[:Status] = nil
    session[:WrkrCompany] = nil
    session[:WrkrOffice] = nil
    session[:Petitioner] = nil
    session[:Balance] = nil
    session[:Client] = nil
    session[:User] = nil
    session[:Period] = nil
    # Ag2Admin
    # ...
    # Ag2Directory
    session[:ContactType] = nil
    # Ag2Finance
    # ...
    # Ag2Gest
    session[:ReadingRoute] = nil
    session[:Meter] = nil
    session[:Caliber] = nil
    session[:RequestType] = nil
    session[:RequestStatus] = nil
    session[:ClientInfo] = nil
    session[:Subscriber] = nil
    session[:SubscriberB] = nil
    session[:Operation] = nil
    session[:Biller] = nil
    session[:BillerB] = nil
    session[:ServicePoint] = nil
    session[:SubscriberCode] = nil
    session[:ClientCode] = nil
    session[:SubscriberFiscal] = nil
    session[:ClientFiscal] = nil
    session[:StreetName] = nil
    session[:StreetNameB] = nil
    session[:entity] = nil
    session[:Request] = nil
    session[:BankAccount] = nil
    session[:BankOrder] = nil
    session[:Use] = nil
    session[:Phase] = nil
    session[:PeriodB] = nil
    session[:ProjectB] = nil
    session[:ClientB] = nil
    # Ag2HelpDesk
    session[:Id] = nil
    session[:OfficeT] = nil
    session[:Category] = nil
    session[:Priority] = nil
    session[:Technician] = nil
    session[:Domain] = nil
    # Ag2Human
    session[:Worker] = nil
    session[:Code] = nil
    # Ag2Products
    session[:Family] = nil
    session[:Store] = nil
    session[:Measure] = nil
    session[:Manufacturer] = nil
    session[:Tax] = nil
    session[:Stores] = nil
    session[:Companies] = nil
    # Ag2Purchase
    session[:Supplier] = nil
    session[:Invoice] = nil
    # Ag2Tech
    session[:Group] = nil
    session[:Area] = nil
    session[:Labor] = nil

    render json: { result: session[:letter] }
  end

  #
  # Special search (select2)
  #
  # Charge accounts
  def search_charge_accounts
    @charge_accounts = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "(projects.company_id = #{session[:company]} OR project_id IS NULL) AND " if session[:company] != '0'
    w = "(projects.office_id = #{session[:office]} OR project_id IS NULL) AND " if session[:office] != '0'
    if @q != ''
      w += "(account_code LIKE '%#{@q}%' OR charge_accounts.name LIKE '%#{@q}%')"
      @charge_accounts = serialized(ChargeAccount.g_where(w),
                                    Api::V1::ChargeAccountsSerializer)
    end
    render json: @charge_accounts
  end

  # Projects charge accounts
  def search_projects_charge_accounts
    projects = params[:projects]
    @charge_accounts = []
    w = ''
    w = "charge_accounts.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "(charge_accounts.project_id IN (#{projects}) OR charge_accounts.project_id IS NULL) AND " if !projects.blank?
    if @q != ''
      w += "(account_code LIKE '%#{@q}%' OR charge_accounts.name LIKE '%#{@q}%')"
      @charge_accounts = serialized(ChargeAccount.g_where(w),
                                    Api::V1::ChargeAccountsSerializer)
    end
    render json: @charge_accounts
  end

  # Projects expenditure charge accounts
  def search_projects_expenditure_charge_accounts
    projects = params[:projects]
    @charge_accounts = []
    w = ''
    w = "charge_accounts.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "(charge_accounts.project_id IN (#{projects}) OR charge_accounts.project_id IS NULL) AND " if !projects.blank?
    if @q != ''
      w += "(account_code LIKE '%#{@q}%' OR charge_accounts.name LIKE '%#{@q}%')"
      @charge_accounts = serialized(ChargeAccount.g_where_expenditures(w),
                                    Api::V1::ChargeAccountsSerializer)
    end
    render json: @charge_accounts
  end

  # Projects income charge accounts
  def search_projects_income_charge_accounts
    projects = params[:projects]
    @charge_accounts = []
    w = ''
    w = "charge_accounts.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "(charge_accounts.project_id IN (#{projects}) OR charge_accounts.project_id IS NULL) AND " if !projects.blank?
    if @q != ''
      w += "(account_code LIKE '%#{@q}%' OR charge_accounts.name LIKE '%#{@q}%')"
      @charge_accounts = serialized(ChargeAccount.g_where_incomes(w),
                                    Api::V1::ChargeAccountsSerializer)
    end
    render json: @charge_accounts
  end

  # Projects
  def search_projects
    @projects = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(project_code LIKE '%#{@q}%' OR name LIKE '%#{@q}%')"
      @projects = serialized(Project.where(w).by_code,
                             Api::V1::ProjectsSerializer)
    end
    render json: @projects
  end

  # Clients
  def search_clients
    @clients = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(client_code LIKE '%#{@q}%' OR last_name LIKE '%#{@q}%' OR first_name LIKE '%#{@q}%' OR company LIKE '%#{@q}%' OR fiscal_id LIKE '%#{@q}%')"
      @clients = serialized(Client.where(w).by_code,
                            Api::V1::ClientsSerializer)
    end
    render json: @clients
  end

  # Subscribers
  def search_subscribers
    @subscribers = []
    w = ''
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(subscriber_code LIKE '%#{@q}%' OR last_name LIKE '%#{@q}%' OR first_name LIKE '%#{@q}%' OR company LIKE '%#{@q}%' OR fiscal_id LIKE '%#{@q}%')"
      @subscribers = serialized(Subscriber.where(w).by_code,
                            Api::V1::SubscribersSerializer)
    end
    render json: @subscribers
  end

  # Client Subscribers
  def search_client_subscribers
    client = params[:client]
    @subscribers = []
    w = ''
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    w = "client_id = #{client} AND " if !client.blank?
    if @q != ''
      w += "(subscriber_code LIKE '%#{@q}%' OR last_name LIKE '%#{@q}%' OR first_name LIKE '%#{@q}%' OR company LIKE '%#{@q}%' OR fiscal_id LIKE '%#{@q}%')"
      @subscribers = serialized(Subscriber.where(w).by_code,
                            Api::V1::SubscribersSerializer)
    end
    render json: @subscribers
  end

  # Companies / Billers
  def search_companies
    @companies = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(fiscal_id LIKE '%#{@q}%' OR name LIKE '%#{@q}%')"
      @companies = serialized(Company.where(w).by_fiscal,
                             Api::V1::CompaniesSerializer)
    end
    render json: @companies
  end

  # Towns
  def search_towns
    @towns = []
    w = ''
    if @q != ''
      w += "name LIKE '%#{@q}%'"
      @towns = serialized(Town.where(w).by_name,
                             Api::V1::TownsSerializer)
    end
    render json: @towns
  end

  # Zipcodes
  def search_zipcodes
    @zipcodes = []
    w = ''
    if @q != ''
      w += "zipcode LIKE '%#{@q}%'"
      @zipcodes = serialized(Zipcode.where(w).by_zipcode,
                             Api::V1::ZipcodesSerializer)
    end
    render json: @zipcodes
  end

  # Work orders
  def search_work_orders
    @work_orders = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "projects.company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "projects.office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(order_no LIKE '%#{@q}%' OR description LIKE '%#{@q}%')"
      @work_orders = serialized(WorkOrder.g_where(w),
                                Api::V1::WorkOrdersSerializer)
    end
    render json: @work_orders
  end

  # Project Work orders
  def search_project_work_orders
    project = params[:project]
    @work_orders = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "projects.company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "projects.office_id = #{session[:office]} AND " if session[:office] != '0'
    w = "project_id = #{project} AND " if !project.blank?
    if @q != ''
      w += "(order_no LIKE '%#{@q}%' OR description LIKE '%#{@q}%')"
      @work_orders = serialized(WorkOrder.g_where(w),
                                Api::V1::WorkOrdersSerializer)
    end
    render json: @work_orders
  end

  # Contracting requests
  def search_contracting_requests
    @contracting_requests = []
    w = ''
    w = "projects.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "projects.company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "projects.office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(
            request_no LIKE '%#{@q}%' OR
            (supply_clients.last_name LIKE '%#{@q}%' OR supply_clients.first_name LIKE '%#{@q}%' OR supply_clients.company LIKE '%#{@q}%') OR
            (connection_clients.last_name LIKE '%#{@q}%' OR connection_clients.first_name LIKE '%#{@q}%' OR connection_clients.company LIKE '%#{@q}%')
            )"
      @contracting_requests = serialized(ContractingRequest.g_where(w),
                                Api::V1::ContractingRequestsSerializer)
    end
    render json: @contracting_requests
  end

  # Suppliers
  def search_suppliers
    @suppliers = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(supplier_code LIKE '%#{@q}%' OR name LIKE '%#{@q}%')"
      @suppliers = serialized(Supplier.where(w).by_code,
                            Api::V1::SuppliersSerializer)
    end
    render json: @suppliers
  end

  # Product families
  def search_product_families
    @product_families = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(family_code LIKE '%#{@q}%' OR name LIKE '%#{@q}%')"
      @product_families = serialized(ProductFamily.where(w).by_code,
                             Api::V1::ProductFamiliesSerializer)
    end
    render json: @product_families
  end

  # Products
  def search_products
    @products = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(product_code LIKE '%#{@q}%' OR main_description LIKE '%#{@q}%')"
      @products = serialized(Product.where(w).by_code,
                             Api::V1::ProductsSerializer)
    end
    render json: @products
  end

  # Billing periods
  def search_billing_periods
    @billing_periods = []
    w = ''
    w = "projects.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    if @q != ''
      w += "(period LIKE '%#{@q}%')"
      @billing_periods = serialized(BillingPeriod.joins(:project).where(w).by_period,
                             Api::V1::BillingPeriodsSerializer)
    end
    render json: @billing_periods
  end

  # Meters
  def search_meters
    @meters = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(meter_code LIKE '%#{@q}%' OR meter_models.model LIKE '%#{@q}%' OR meter_brands.brand LIKE '%#{@q}%' OR calibers.caliber LIKE '%#{@q}%')"
      @meters = serialized(Meter.g_where(w),
                            Api::V1::MetersSerializer)
    end
    render json: @meters
  end

  # Subscriber Meter
  def search_subscriber_meter
    subscriber = params[:subscriber]
    @meters = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    w = "subscribers.id = #{subscriber} AND " if !subscriber.blank?
    if @q != ''
      w += "(meter_code LIKE '%#{@q}%' OR meter_models.model LIKE '%#{@q}%' OR meter_brands.brand LIKE '%#{@q}%' OR calibers.caliber LIKE '%#{@q}%')"
      @meters = serialized(Meter.g_where_with_subscribers(w),
                            Api::V1::MetersSerializer)
    end
    render json: @meters
  end

  # Charge users
  def search_users
    @users = []
    w = ''
    w = "users_organizations.organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "users_companies.company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "users_offices.office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(users.email LIKE '%#{@q}%' OR users.name LIKE '%#{@q}%')"
      @users = serialized(User.g_where(w),
                          Api::V1::UsersSerializer)
    end
    render json: @users
  end

  # Stores
  def search_stores
    @stores = []
    w = ''
    w = "organization_id = #{session[:organization]} AND " if session[:organization] != '0'
    w = "company_id = #{session[:company]} AND " if session[:company] != '0'
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(name LIKE '%#{@q}%')"
      @stores = serialized(Store.where(w).by_name,
                            Api::V1::StoresSerializer)
    end
    render json: @stores
  end

  # Stores
  def search_reading_routes
    @routes = []
    w = ''
    w = "office_id = #{session[:office]} AND " if session[:office] != '0'
    if @q != ''
      w += "(routing_code LIKE '%#{@q}%' OR name LIKE '%#{@q}%')"
      @routes = serialized(ReadingRoute.where(w).by_code,
                             Api::V1::ReadingRoutesSerializer)
    end
    render json: @routes
  end

  # Returns JSON list of data
  def serialized(_data, _serializer)
    ActiveModel::ArraySerializer.new(_data, each_serializer: _serializer, root: false)
  end

  def set_params
    @q = params[:q]
    @page = params[:page]
  end
end
