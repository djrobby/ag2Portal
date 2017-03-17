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
    session[:Operation] = nil
    session[:Biller] = nil
    session[:ServicePoint] = nil
    session[:StreetName] = nil
    session[:entity] = nil
    session[:Request] = nil
    session[:Use] = nil
    # Ag2HelpDesk
    session[:Id] = nil
    session[:User] = nil
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
    session[:Client] = nil
    session[:Stores] = nil
    session[:Companies] = nil
    # Ag2Purchase
    session[:Supplier] = nil
    session[:Invoice] = nil
    # Ag2Tech
    session[:Period] = nil
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
      w += "(client_code LIKE '%#{@q}%' OR last_name LIKE '%#{@q}%' OR first_name LIKE '%#{@q}%' OR company LIKE '%#{@q}%')"
      @clients = serialized(Client.where(w).by_code,
                            Api::V1::ClientsSerializer)
    end
    render json: @clients
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

  # Returns JSON list of orders
  def serialized(_data, _serializer)
    ActiveModel::ArraySerializer.new(_data, each_serializer: _serializer, root: false)
  end

  def set_params
    @q = params[:q]
    @page = params[:page]
  end

  def ret_array(_search)
    _array = []
    _search.each do |i|
      _array = _array << [i.id, i.full_no]
    end
    _array
  end
end
