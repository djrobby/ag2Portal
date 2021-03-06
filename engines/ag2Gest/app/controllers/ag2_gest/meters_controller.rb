require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MetersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column
    skip_load_and_authorize_resource :only => [ :me_update_office_select_from_company,
                                                :me_update_company_select_from_organization,
                                                :meter_view_report]

    # Update office select at view from company select
    def me_update_office_select_from_company
      company = params[:meter]
      if company != '0'
        @company = Company.find(company)
        @offices = @company.blank? ? offices_dropdown : offices_by_company(@company)
      else
        @offices = offices_dropdown
      end
      render json: { "offices" => @offices }
    end

    # Update company select at view from organization select
    def me_update_company_select_from_organization
      organization = params[:meter]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? companies_dropdown : @organization.companies.order(:name)
        @offices = @organization.blank? ? offices_dropdown : @organization.offices.order(:office_code)
      else
        @companies = companies_dropdown
        @offices = offices_dropdown
      end
      @json_data = { "companies" => @companies, "offices" => @offices }
      render json: @json_data
    end

     # meter report
    def meter_view_report
      manage_filter_state

      code = params[:Code]
      model = params[:Model]
      brand = params[:Brand]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]


      # If inverse no search is required
      meter_code = !meter_code.blank? && meter_code[0] == '%' ? inverse_no_search(meter_code) : meter_code

      @search = Meter.search do
        if session[:office] != '0'
          with :office_id, session[:office]
        elsif session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !code.blank?
          if code.class == Array
            with :meter_code, code
          else
            with(:meter_code).starting_with(code)
          end
        end
        if !model.blank?
          with :meter_model_id, model
        end
        if !brand.blank?
          with :meter_brand_id, brand
        end
        if !caliber.blank?
          with :caliber_id, caliber
        end
        if !from.blank?
          any_of do
            with(:purchase_date).greater_than(from)
            with :purchase_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:purchase_date).less_than(to)
            with :purchase_date, to
          end
        end
          #order_by :order_route, :desc
          paginate :page => params[:page] || 1, :per_page => Meter.count
      end

      # @meter_report = @search.results.sort_by{ |t| [t.order_route, t.order_sequence] }
      meter_ids = []
      @search.hits.each do |i|
        meter_ids << i.result.id
      end
      @meter_report = Meter.with_these_ids(meter_ids).sort_by{ |t| [t.order_route, t.order_sequence] }

      if !@meter_report.blank?
        title = t("activerecord.models.meter.few")
        @from = formatted_date(@meter_report.first.created_at)
        @to = formatted_date(@meter_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

    # def me_find_meter
    #   m = params[:meter]
    #   alert = ""
    #   code = ''
    #   meter_id = 0
    #   if m != '0'
    #     meter = Meter.find_by_meter_code(m) rescue nil
    #     if !meter.nil?
    #         # Meter available
    #         alert = I18n.t("activerecord.errors.models.meter.available_c", var: m)
    #         meter_id = meter.id
    #     else
    #       # Meter code not found
    #       alert = I18n.t("activerecord.errors.models.meter.code_not_found", var: m)
    #       code = '$err'
    #     end
    #   else
    #     # Wrong meter code
    #     alert = I18n.t("activerecord.errors.models.meter.code_wrong", var: m)
    #     code = '$err'
    #   end
    #   # Setup JSON
    #   @json_data = { "code" => code, "alert" => alert, "meter_id" => meter_id.to_s }
    #   render json: @json_data
    # end

    #
    # Default Methods
    #
    # GET /meters
    # GET /meters.json
    def index
      manage_filter_state

      code = params[:Code]
      model = params[:Model]
      brand = params[:Brand]
      caliber = params[:Caliber]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      meter_code = !meter_code.blank? && meter_code[0] == '%' ? inverse_no_search(meter_code) : meter_code

      @search = Meter.search do
        if session[:office] != '0'
          with :office_id, session[:office]
        elsif session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !code.blank?
          if code.class == Array
            with :meter_code_s, code
          else
            with(:meter_code_s).starting_with(code)
          end
        end
        if !model.blank?
          with :meter_model_id, model
        end
        if !brand.blank?
          with :meter_brand_id, brand
        end
        if !caliber.blank?
          with :caliber_id, caliber
        end
        if !from.blank?
          any_of do
            with(:purchase_date).greater_than(from)
            with :purchase_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:purchase_date).less_than(to)
            with :purchase_date, to
          end
        end
        data_accessor_for(Meter).include = [:caliber, {meter_model: :meter_brand}]
        order_by sort_column, sort_direction
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @meters = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meters }
        format.js
      end
    end

    # GET /meters/1
    # GET /meters/1.json
    def show
      @breadcrumb = 'read'
      @meter = Meter.find(params[:id])
      @details = @meter.meter_details.paginate(:page => params[:page], :per_page => per_page).by_dates
      @readings = @meter.readings.paginate(:page => params[:page], :per_page => per_page).by_period_date
      @child_meters = @meter.child_meters.paginate(:page => params[:page], :per_page => per_page).by_code
      @reading = Reading.new
      @billing_period = billing_periods_dropdown(@meter.office_id)
      @reading_incidence = ReadingIncidenceType.all
      @reading_type = ReadingType.single_manual_reading
      @project_dropdown = projects_dropdown
      @subscriber = @meter.subscribers.activated.size > 1 ? nil : @meter.subscribers.activated.first
      @service_point = @meter.service_points.size > 1 ? nil : @meter.service_points.first

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter }
      end
    end

    # GET /meters/new
    # GET /meters/new.json
    def new
      @breadcrumb = 'create'
      @meter = Meter.new
      @companies = companies_dropdown
      # @master_meter = master_meters_dropdown(nil)
      @master_meter = " "

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter }
      end
    end

    # GET /meters/1/edit
    def edit
      @breadcrumb = 'update'
      @meter = Meter.find(params[:id])
      @companies = @meter.organization.blank? ? companies_dropdown : companies_dropdown_edit(@meter.organization)
      # @master_meter = master_meters_dropdown(@meter.id)
      @master_meter = @meter.master_meter.blank? ? " " : @meter.master_meter.meter_code
    end

    # POST /meters
    # POST /meters.json
    def create
      @breadcrumb = 'create'
      @meter = Meter.new(params[:meter])
      @meter.created_by = current_user.id if !current_user.nil?
      @meter.master_meter_id = params[:Meter].to_i unless params[:Meter].blank?
      # office = Office.find(params[:meter][:office_id])
      # @meter.company_id = office.company_id
      # @meter.organization_id = office.try(:company).try(:organization_id)

      respond_to do |format|
        if @meter.save
          format.html { redirect_to @meter, notice: crud_notice('created', @meter) }
          format.json { render json: @meter, status: :created, location: @meter }
        else
          @companies = companies_dropdown
          # @master_meter = master_meters_dropdown(nil)
          @master_meter = " "
          format.html { render action: "new" }
          format.json { render json: @meter.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meters/1
    # PUT /meters/1.json
    def update
      @breadcrumb = 'update'
      @meter = Meter.find(params[:id])
      @meter.updated_by = current_user.id if !current_user.nil?
      @meter.master_meter_id = params[:Meter].to_i unless params[:Meter].blank?

      respond_to do |format|
        if @meter.update_attributes(params[:meter])
          format.html { redirect_to @meter,
                        notice: (crud_notice('updated', @meter) + "#{undo_link(@meter)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @meter.organization.blank? ? companies_dropdown : companies_dropdown_edit(@meter.organization)
          # @master_meter = master_meters_dropdown(@meter.id)
          @master_meter = @meter.master_meter.blank? ? " " : @meter.master_meter.meter_code
          format.html { render action: "edit" }
          format.json { render json: @meter.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meters/1
    # DELETE /meters/1.json
    def destroy
      @meter = Meter.find(params[:id])

      respond_to do |format|
        if @meter.destroy
          format.html { redirect_to meters_url,
                      notice: (crud_notice('destroyed', @meter) + "#{undo_link(@meter)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meters_url, alert: "#{@meter.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Meter.column_names.include?(params[:sort]) ? params[:sort] : "meter_code"
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      Meter.where('meter_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.meter_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def master_meters_dropdown(_this = nil)
      if !_this.blank?
        # Not including current meter
        if session[:office] != '0'
          Meter.where('(office_id = ? OR (office_id IS NULL AND organization_id = ?)) AND id <> ?', session[:office].to_i, session[:organization].to_i, _this).by_code
        elsif session[:company] != '0'
          Meter.where('(company_id = ? OR (company_id IS NULL AND organization_id = ?)) AND id <> ?', session[:company].to_i, session[:organization].to_i, _this).by_code
        else
          session[:organization] != '0' ? Meter.where('organization_id = ? AND id <> ?', session[:organization].to_i, _this).by_code : Meter.where('id <> ?', _this).by_code
        end
      else
        # All organization's meters
        if session[:office] != '0'
          Meter.where('office_id = ? OR (office_id IS NULL AND organization_id = ?)', session[:office].to_i, session[:organization].to_i).by_code
        elsif session[:company] != '0'
          Meter.where('company_id = ? OR (company_id IS NULL AND organization_id = ?)', session[:company].to_i, session[:organization].to_i).by_code
        else
          session[:organization] != '0' ? Meter.where(organization_id: session[:organization].to_i).by_code : Meter.by_code
        end
      end
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).ser_or_tca_order_type
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).ser_or_tca_order_type
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).ser_or_tca_order_type : Project.ser_or_tca_order_type
      end
    end

    def projects_dropdown_ids
      projects_dropdown.pluck(:id)
    end


    def companies_dropdown
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def companies_dropdown_edit(_organization)
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = _organization.companies.order(:name)
      end
    end

    def offices_dropdown
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = session[:organization] != '0' ? Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name) : Office.order(:name)
      end
    end

    def offices_dropdown_edit(_organization)
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = Office.joins(:company).where(companies: { organization_id: _organization }).order(:name)
      end
    end

    def offices_by_company(_company)
      Office.where(company_id: _company).order(:name)
    end

    def billing_periods_dropdown(o)
      if !o.blank?
        billing_periods_by_office(o)
      else
        BillingPeriod.by_period_desc
      end
    end

    def billing_periods_by_office(o)
      BillingPeriod.belongs_to_office(o)
    end

    # Keeps filter state
    def manage_filter_state
      # Code
      if params[:Code]
        session[:Code] = params[:Code]
      elsif session[:Code]
        params[:Code] = session[:Code]
      end

      # Model
      if params[:Model]
        session[:Model] = params[:Model]
      elsif session[:Model]
        params[:Model] = session[:Model]
      end

      # Brand
      if params[:Brand]
        session[:Brand] = params[:Brand]
      elsif session[:Brand]
        params[:Brand] = session[:Brand]
      end

      # Caliber
      if params[:Caliber]
        session[:Caliber] = params[:Caliber]
      elsif session[:Caliber]
        params[:Caliber] = session[:Caliber]
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
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end

  end
end
