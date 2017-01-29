require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column
    skip_load_and_authorize_resource :only => [ :update_offices_textfield_from_company,
                                                :update_province_textfield_from_town,
                                                :update_province_textfield_from_zipcode,
                                                :update_country_textfield_from_region,
                                                :update_region_textfield_from_province,
                                                :create,
                                                :update_province_textfield_from_street_directory
                                                ]


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

    #NESTOR METHODS #############################################

    # Update country text field at view from region select
    def update_country_textfield_from_region

      if params[:id] == "0"
        @json_data = []
      else
        @region = Region.find(params[:id])
        @country = Country.find(@region.country)
      end

      respond_to do |format|
        format.html # update_country_textfield_from_region.html.erb does not exist! JSON only
        format.json { render json: @country }
      end
    end

    # Update region and country text fields at view from town select
    def update_region_textfield_from_province

      if params[:id] == "0"
        @json_data = []
      else
        @province = Province.find(params[:id])
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "region_id" => @region.id, "country_id" => @country.id }
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update province, region and country text fields at view from town select
    def update_province_textfield_from_town

      if params[:id] == "0"
        @json_data = []
      else
        @town = Town.find(params[:id])
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
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

    # GET /service_point
    def index
      manage_filter_state

      if session[:company] != '0'
        @service_points = ServicePoint.where(company_id: session[:company]).paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction) #Array de ServicePoints
      else
        @service_points = ServicePoint.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)
      end

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
      set_office_company

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point }
      end
    end

    # GET /service_point
    def edit
      @breadcrumb = 'update'
      @service_point = ServicePoint.find(params[:id])
      set_office_company
    end

    # POST /service
    def create
      @breadcrumb = 'create'
      @service_point = ServicePoint.new(params[:service_point])
      @service_point.created_by = current_user.id if !current_user.nil?
      set_office_company

      respond_to do |format|
        if @service_point.save
          format.json { render json: @service_point.to_json(:methods => :to_full_label) }
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.service_point.create') }
        else
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
      set_office_company

      respond_to do |format|
        if @service_point.update_attributes(params[:service_point])
          format.html { redirect_to @service_point,
                        notice: (crud_notice('updated', @service_point) + "#{undo_link(@service_point)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point
    def destroy
      @service_point = ServicePoint.find(params[:id])
      @service_point.destroy

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

    def set_office_company
      @company = Company.find_by_id session[:company]
      @offices = @company.nil? ? Office.all : @company.offices
    end

    def sort_column
      ServicePoint.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    # Keeps filter state
    def manage_filter_state
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
