require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column
    skip_load_and_authorize_resource :only => [ :update_offices_textfield_from_company,
                                                :update_province_textfield_from_zipcode,
                                                :create,
                                                :update_province_textfield_from_street_directory,
                                                :serpoint_generate_no]


    # Update province text field at view from town select
    def update_offices_textfield_from_company

      if params[:id] == "0"
        @offices = []
      else
        @offices = Company.find(params[:id]).offices
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @offices }
      end
    end

    # Update town, province, region and country text fields at view from zip code select
    def update_province_textfield_from_zipcode

      if params[:id] == "0"
        @json_data = []
      else
        @zipcode = Zipcode.find(params[:id])
        @town = Town.find(@zipcode.town)
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update fileds from street_directory
    def update_province_textfield_from_street_directory

      if params[:id] == "0"
        @json_data = []
      else
        @street_directory = StreetDirectory.find(params[:id])
        @street_type = StreetType.find(@street_directory.street_type)
        @street_name = StreetDirectory.find(params[:id]).street_name
        @town = Town.find(@street_directory.town)
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id, "street_type_id" => @street_type.id, "street_name" => @street_name}
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update service point code at view (generate_code_sp_btn)
    def serpoint_generate_no
      office = params[:id]
      # Builds code, if possible
      code = office == '$' ? '$err' : serpoint_next_no(office)
      @json_data = { "code" => code }
      render json: @json_data
    end


    # GET /service_point
    def index
      manage_filter_state
      letter = params[:letter]
      if !session[:organization]
        init_oco
      end

      @search = ServicePoint.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          any_of do
            with(:service_address).starting_with(letter)
          end
        end
        order_by :code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @service_points = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_points }
        format.js
      end
    end


    # GET /service_point
    def show
      @breadcrumb = 'read'
      @service_point = ServicePoint.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point }
      end
    end

    # GET /service_point
    def new
      @breadcrumb = 'create'
      @service_point = ServicePoint.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @reading_routes = reading_routes_dropdown
      @zipcodes = zipcodes_dropdown
      if session[:office] != '0'
        @office_center = Office.find(session[:office])
        @centers = Center.where(town_id: @office_center.town_id.to_i).order('name')
      else
        @centers = Center.all(order: 'name')
      end

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point }
      end
    end

    # GET /service_point
    def edit
      @breadcrumb = 'update'
      @service_point = ServicePoint.find(params[:id])
      @companies = @service_point.organization.blank? ? companies_dropdown : companies_dropdown_edit(@service_point.organization)
      @offices = @service_point.organization.blank? ? offices_dropdown : offices_dropdown_edit(@service_point.organization_id)
      @reading_routes = reading_routes_dropdown
      @zipcodes = zipcodes_dropdown
      if session[:office] != '0'
        @office_center = Office.find(session[:office])
        @centers = Center.where(town_id: @office_center.town_id.to_i).order('name')
      else
        @centers = Center.all(order: 'name')
      end
    end

    # POST /service
    def create
      @breadcrumb = 'create'
      @service_point = ServicePoint.new(params[:service_point])
      @service_point.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point.save
          format.json { render json: @service_point.to_json(:methods => :to_full_label) }
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.service_point.create') }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          @reading_routes = reading_routes_dropdown
          @zipcodes = zipcodes_dropdown
          format.html { render action: "new" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /service_point
    def update
      @breadcrumb = 'update'
      @service_point = ServicePoint.find(params[:id])
      @service_point.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point.update_attributes(params[:service_point])
          format.html { redirect_to @service_point,
                        notice: (crud_notice('updated', @service_point) + "#{undo_link(@service_point)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @project.organization.blank? ? companies_dropdown : companies_dropdown_edit(@project.organization)
          @offices = @project.organization.blank? ? offices_dropdown : offices_dropdown_edit(@project.organization_id)
          @reading_routes = reading_routes_dropdown
          @zipcodes = zipcodes_dropdown
          format.html { render action: "edit" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point
    def destroy
      @service_point = ServicePoint.find(params[:id])

      respond_to do |format|
        if @service_point.destroy
          format.html { redirect_to service_points_url,
                      notice: (crud_notice('destroyed', @service_point) + "#{undo_link(@service_point)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to service_points_url, alert: "#{@service_point.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def zipcodes_dropdown
      Zipcode.order(:zipcode).includes(:town,:province)
    end

    def companies_dropdown
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
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

    def companies_dropdown_edit(_organization)
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = _organization.companies.order(:name)
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

    def reading_routes_dropdown
      if session[:office] != '0'
        ReadingRoute.by_office(session[:office].to_i)
      else
        ReadingRoute.by_code
      end
    end

    def sort_column
      ServicePoint.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
