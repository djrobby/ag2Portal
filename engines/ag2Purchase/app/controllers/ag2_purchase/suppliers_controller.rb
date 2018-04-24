require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SuppliersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:su_update_textfields_from_organization,
                                               :update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_country_textfield_from_region,
                                               :update_region_textfield_from_province,
                                               :su_generate_code,
                                               :et_validate_fiscal_id_textfield,
                                               :su_validate_fiscal_id_textfield,
                                               :su_format_amount,
                                               :su_format_percentage,
                                               :su_update_office_select_from_bank,
                                               :su_update_ledger_account_select_from_company,
                                               :su_check_iban]
    # Update payment method and ledger account text fields at view from organization select
    def su_update_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @payment_methods = @organization.blank? ? payment_methods_dropdown : payment_payment_methods(@organization.id)
        @ledger_accounts = @organization.blank? ? ledger_accounts_dropdown : @organization.ledger_accounts.order(:code)
      else
        @payment_methods = payment_methods_dropdown
        @ledger_accounts = ledger_accounts_dropdown
      end
      # Ledger accounts array
      @ledger_accounts_dropdown = ledger_accounts_array(@ledger_accounts)
      # Setup JSON
      @json_data = { "payment_method" => @payment_methods, "accounts" => @ledger_accounts_dropdown }
      render json: @json_data
    end

    # Update country text field at view from region select
    def update_country_textfield_from_region
      @region = Region.find(params[:id])
      @country = Country.find(@region.country)

      respond_to do |format|
        format.html # update_country_textfield_from_region.html.erb does not exist! JSON only
        format.json { render json: @country }
      end
    end

    # Update region and country text fields at view from town select
    def update_region_textfield_from_province
      @province = Province.find(params[:id])
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update province, region and country text fields at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update town, province, region and country text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update supplier code at view (generate_code_btn)
    def su_generate_code
      activity = params[:activity]
      organization = params[:org]

      # Builds code, if possible
      if activity == '$' || organization == '$'
        code = '$err'
      else
        code = su_next_code(organization, activity)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    # Search Entity
    def su_validate_fiscal_id_textfield
      id = ''
      fiscal_id = ''
      name = ''
      street_type_id = ''
      street_name = ''
      street_number = ''
      building = ''
      floor = ''
      floor_office = ''
      zipcode_id = ''
      town_id = ''
      province_id = ''
      region_id = ''
      country_id = ''
      phone = ''
      fax = ''
      cellular = ''
      email = ''
      organization_id = ''
      code = ''

      if params[:id] == '0'
        id = '$err'
        fiscal_id = '$err'
      else
        if session[:organization] != '0'
          @entity = Entity.find_by_fiscal_id_and_organization(params[:id], session[:organization])
        else
          @entity = Entity.find_by_fiscal_id(params[:id])
        end
        if @entity.nil?
          id = '$err'
          fiscal_id = '$err'
        else
          id = @entity.id
          fiscal_id = @entity.fiscal_id
          if @entity.entity_type_id < 2
            name = @entity.full_name
          else
            name = @entity.company
          end
          street_type_id = @entity.street_type_id
          street_name = @entity.street_name
          street_number = @entity.street_number
          building = @entity.building
          floor = @entity.floor
          floor_office = @entity.floor_office
          zipcode_id = @entity.zipcode_id
          town_id = @entity.town_id
          province_id = @entity.province_id
          region_id = @entity.region_id
          country_id = @entity.country_id
          phone = @entity.phone
          fax = @entity.fax
          cellular = @entity.cellular
          email = @entity.email
          organization_id = @entity.organization_id
          # Must check if already exist
          if !Supplier.find_by_fiscal_id(params[:id]).nil?
            code = I18n.t("activerecord.errors.models.supplier.already_exists")
          end
        end
      end

      @json_data = { "id" => id, "fiscal_id" => fiscal_id, "name" => name,
                     "street_type_id" => street_type_id, "street_name" => street_name,
                     "street_number" => street_number, "building" => building,
                     "floor" => floor, "floor_office" => floor_office,
                     "zipcode_id" => zipcode_id, "town_id" => town_id,
                     "province_id" => province_id, "region_id" => region_id,
                     "country_id" => country_id, "phone" => phone,
                     "fax" => fax, "cellular" => cellular, "email" => email,
                     "organization_id" => organization_id, "code" => code }

      respond_to do |format|
        format.html # validate_fiscal_id_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Format amount properly
    def su_format_amount
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Format percentage properly
    def su_format_percentage
      num = params[:num].to_f / 100
      num = number_with_precision(num.round(2), precision: 2)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    # Validate entity fiscal id (modal)
    def et_validate_fiscal_id_textfield
      fiscal_id = params[:id]
      dc = ''
      f_id = 'OK'
      f_name = ''

      if fiscal_id == '0'
        f_id = '$err'
      else
        dc = fiscal_id_dc(fiscal_id)
        if dc == '$par' || dc == '$err'
          f_id = '$err'
        else
          if dc == '$uni'
            f_id = '??'
          end
          f_name = fiscal_id_description(fiscal_id[0])
          if f_name == '$err'
            f_name = I18n.t("ag2_admin.entities.fiscal_name")
          end
        end
      end

      @json_data = { "fiscal_id" => f_id, "fiscal_name" => f_name }
      render json: @json_data
    end

    # Update office select at view from bank select
    def su_update_office_select_from_bank
      bank = params[:bank]
      if bank != '0'
        @bank = Bank.find(bank)
        @offices = @bank.blank? ? bank_offices_dropdown : @bank.bank_offices.order(:bank_id, :code)
      else
        @offices = bank_offices_dropdown
      end
      # Offices array
      @offices_dropdown = bank_offices_array(@offices)
      # Setup JSON
      @json_data = { "office" => @offices_dropdown }
      render json: @json_data
    end

    # Update ledger account select at view from company select
    def su_update_ledger_account_select_from_company
      company = params[:company]
      if company != '0'
        @company = Company.find(company)
        @ledger_accounts = @company.blank? ? ledger_accounts_by_company_dropdown : @company.ledger_accounts.by_code
      else
        @ledger_accounts = ledger_accounts_by_company_dropdown
      end
      # Accounts array
      @ledger_accounts_dropdown = ledger_accounts_array(@ledger_accounts)
      # Setup JSON
      @json_data = { "ledger_account" => @ledger_accounts_dropdown }
      render json: @json_data
    end

    # Check Fiscal Id
    def su_check_fiscal_id
      fiscal_id = params[:contact]
      # Setup JSON
      @json_data = { "iban" => iban }
      render json: @json_data
    end

    # Check IBAN
    def su_check_iban
      iban = check_iban(params[:country], params[:dc], params[:bank], params[:office], params[:account])
      # Setup JSON
      @json_data = { "iban" => iban }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /suppliers
    # GET /suppliers.json
    def index
      manage_filter_state
      letter = params[:letter]
      if !session[:organization]
        init_oco
      end

      @search = Supplier.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          with(:name).starting_with(letter)
        end
        order_by :supplier_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @suppliers = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @suppliers }
        format.js
      end
    end

    # GET /suppliers/1
    # GET /suppliers/1.json
    def show
      @breadcrumb = 'read'
      @supplier = Supplier.find(params[:id])
      @contacts = @supplier.supplier_contacts.paginate(:page => params[:page], :per_page => per_page).order(:last_name, :first_name)
      @prices = @supplier.purchase_prices.paginate(:page => params[:page], :per_page => per_page).order(:product_id)
      @accounts = @supplier.supplier_bank_accounts.paginate(:page => params[:page], :per_page => per_page).order(:id)
      @ledger_accounts = @supplier.supplier_ledger_accounts.paginate(:page => params[:page], :per_page => per_page).order(:id)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier }
      end
    end

    # GET /suppliers/new
    # GET /suppliers/new.json
    def new
      @breadcrumb = 'create'
      @supplier = Supplier.new
      @payment_methods = payment_methods_dropdown
      @ledger_accounts = ledger_accounts_dropdown
      @classes = bank_account_classes_dropdown
      @countries = countries_dropdown
      # @banks = banks_dropdown
      # @offices = bank_offices_dropdown
      @companies = companies_dropdown
      @ledger_accounts_by_company = ledger_accounts_by_company_dropdown
      @withholding_types = WithholdingType.current
      @towns = towns_dropdown
      @provinces = provinces_dropdown
      @zipcodes = zipcodes_dropdown
      @regions = Region.order(:name)

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier }
      end
    end

    # GET /suppliers/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier = Supplier.find(params[:id])
      @payment_methods = @supplier.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@supplier.organization_id)
      @ledger_accounts = ledger_accounts_dropdown
      @classes = bank_account_classes_dropdown
      @countries = countries_dropdown
      # @banks = banks_dropdown
      # @offices = bank_offices_dropdown
      @companies = companies_dropdown
      @ledger_accounts_by_company = ledger_accounts_by_company_dropdown
      @withholding_types = WithholdingType.current
      @towns = towns_dropdown
      @provinces = provinces_dropdown
      @zipcodes = zipcodes_dropdown
      @regions = Region.order(:name)
    end

    # POST /suppliers
    # POST /suppliers.json
    def create
      @breadcrumb = 'create'
      @supplier = Supplier.new(params[:supplier])
      @supplier.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier.save
          format.html { redirect_to @supplier, notice: crud_notice('created', @supplier) }
          format.json { render json: @supplier, status: :created, location: @supplier }
        else
          @payment_methods = payment_methods_dropdown
          @ledger_accounts = ledger_accounts_dropdown
          @classes = bank_account_classes_dropdown
          @countries = countries_dropdown
          # @banks = banks_dropdown
          # @offices = bank_offices_dropdown
          @companies = companies_dropdown
          @ledger_accounts_by_company = ledger_accounts_by_company_dropdown
          @towns = towns_dropdown
          @provinces = provinces_dropdown
          @zipcodes = zipcodes_dropdown
          @regions = Region.order(:name)
          format.html { render action: "new" }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /suppliers/1
    # PUT /suppliers/1.json
    def update
      @breadcrumb = 'update'
      @supplier = Supplier.find(params[:id])
      @supplier.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier.update_attributes(params[:supplier])
          format.html { redirect_to @supplier,
                        notice: (crud_notice('updated', @supplier) + "#{undo_link(@supplier)}").html_safe }
          format.json { head :no_content }
        else
          @payment_methods = @supplier.organization.blank? ? payment_methods_dropdown : payment_payment_methods(@supplier.organization_id)
          @ledger_accounts = ledger_accounts_dropdown
          @classes = bank_account_classes_dropdown
          @countries = countries_dropdown
          # @banks = banks_dropdown
          # @offices = bank_offices_dropdown
          @companies = companies_dropdown
          @ledger_accounts_by_company = ledger_accounts_by_company_dropdown
          @towns = towns_dropdown
          @provinces = provinces_dropdown
          @zipcodes = zipcodes_dropdown
          @regions = Region.order(:name)
          format.html { render action: "edit" }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /suppliers/1
    # DELETE /suppliers/1.json
    def destroy
      @supplier = Supplier.find(params[:id])

      respond_to do |format|
        if @supplier.destroy
          format.html { redirect_to suppliers_url,
                      notice: (crud_notice('destroyed', @supplier) + "#{undo_link(@supplier)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to suppliers_url, alert: "#{@supplier.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def towns_dropdown
      Town.order(:name).includes(:province)
    end

    def provinces_dropdown
      Province.order(:name).includes(:region)
    end

    def zipcodes_dropdown
      Zipcode.order(:zipcode).includes(:town,:province)
    end

    # Ledger accounts belonging to projects
    def projects_ledger_accounts(_projects)
      _array = []
      _ret = nil

      # Adding ledger accounts belonging to current projects
      _projects.each do |i|
        _ret = LedgerAccount.where(project_id: i.id)
        ret_array(_array, _ret, 'id')
      end

      # Adding global ledger accounts belonging to projects organizations
      _sort_projects_by_organization = _projects.sort { |a,b| a.organization_id <=> b.organization_id }
      _previous_organization = _sort_projects_by_organization.first.organization_id
      _sort_projects_by_organization.each do |i|
        if _previous_organization != i.organization_id
          # when organization changes, process previous
          _ret = LedgerAccount.where('(project_id IS NULL AND ledger_accounts.organization_id = ?)', _previous_organization)
          ret_array(_array, _ret, 'id')
          _previous_organization = i.organization_id
        end
      end
      # last organization, process previous
      _ret = LedgerAccount.where('(project_id IS NULL AND ledger_accounts.organization_id = ?)', _previous_organization)
      ret_array(_array, _ret, 'id')

      # Returning founded ledger accounts
      _ret = LedgerAccount.where(id: _array).order(:code)
    end

    def projects_dropdown
      _projects = nil
      _oco = false
      if session[:office] != '0'
        _projects = Project.active_only.where(office_id: session[:office].to_i)
        _oco = true
      elsif session[:company] != '0'
        _projects = Project.active_only.where(company_id: session[:company].to_i)
        _oco = true
      elsif session[:organization] != '0'
        _projects = Project.active_only.where(organization_id: session[:organization].to_i)
        _oco = true
      end
      return _projects, _oco
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

    def companies_dropdown
      if session[:company] != '0'
        Company.where(id: session[:company].to_i)
      else
        session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def ledger_accounts_dropdown
      _projects, _oco = projects_dropdown
      if _oco == false
        LedgerAccount.order(:code)
      else
        if _projects.blank?
          session[:organization] != '0' ? LedgerAccount.where(organization_id: session[:organization].to_i).order(:code) : LedgerAccount.order(:code)
        else
          projects_ledger_accounts(_projects)
        end
      end
    end

    def ledger_accounts_by_company_dropdown
      if session[:company] != '0'
        LedgerAccount.belongs_to_company(session[:company].to_i)
      else
        session[:organization] != '0' ? LedgerAccount.belongs_to_organization(session[:organization].to_i) : LedgerAccount.by_code
      end
    end

    def bank_account_classes_dropdown
      BankAccountClass.where('id >= ?', 5).order(:id)
    end

    def countries_dropdown
      Country.order(:code)
    end

    def banks_dropdown
      Bank.order(:code)
    end

    def bank_offices_dropdown
      BankOffice.order(:bank_id, :code)
    end

    def bank_offices_array(_offices)
      _array = []
      _offices.each do |i|
        _array = _array << [i.id, i.code, i.name, "(" + i.bank.code + ")"]
      end
      _array
    end

    def ledger_accounts_array(_accounts)
      _array = []
      _accounts.each do |i|
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

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end

    def reset_stock_prices_filter
      session[:Products] = nil
      session[:Suppliers] = nil
    end
  end
end
