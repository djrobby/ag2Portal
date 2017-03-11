require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class BankOfficesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:bo_update_province_textfield_from_town,
                                               :bo_update_province_textfield_from_zipcode,
                                               :bo_update_country_textfield_from_region,
                                               :bo_update_region_textfield_from_province]
    # Helper methods for sorting
    helper_method :sort_column

    # Update province, region and country text fields at view from town select
    def bo_update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }
      render json: @json_data
    end

    # Update town, province, region and country text fields at view from zip code select
    def bo_update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }
      render json: @json_data
    end

    # Update country text field at view from region select
    def bo_update_country_textfield_from_region
      @region = Region.find(params[:id])
      @country = Country.find(@region.country)
      render json: @country
    end

    # Update region and country text fields at view from town select
    def bo_update_region_textfield_from_province
      @province = Province.find(params[:id])
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "region_id" => @region.id, "country_id" => @country.id }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /bank_offices
    # GET /bank_offices.json
    def index
      manage_filter_state
      @bank_offices = BankOffice.includes(:bank, :street_type, :zipcode, :town).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bank_offices }
        format.js
      end
    end

    # GET /bank_offices/1
    # GET /bank_offices/1.json
    def show
      @breadcrumb = 'read'
      @bank_office = BankOffice.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @bank_office }
      end
    end

    # GET /bank_offices/new
    # GET /bank_offices/new.json
    def new
      @breadcrumb = 'create'
      @bank_office = BankOffice.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @bank_office }
      end
    end

    # GET /bank_offices/1/edit
    def edit
      @breadcrumb = 'update'
      @bank_office = BankOffice.find(params[:id])
    end

    # POST /bank_offices
    # POST /bank_offices.json
    def create
      @breadcrumb = 'create'
      @bank_office = BankOffice.new(params[:bank_office])
      @bank_office.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @bank_office.save
          format.html { redirect_to @bank_office, notice: crud_notice('created', @bank_office) }
          format.json { render json: @bank_office, status: :created, location: @bank_office }
        else
          format.html { render action: "new" }
          format.json { render json: @bank_office.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /bank_offices/1
    # PUT /bank_offices/1.json
    def update
      @breadcrumb = 'update'
      @bank_office = BankOffice.find(params[:id])
      @bank_office.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @bank_office.update_attributes(params[:bank_office])
          format.html { redirect_to @bank_office,
                        notice: (crud_notice('updated', @bank_office) + "#{undo_link(@bank_office)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @bank_office.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /bank_offices/1
    # DELETE /bank_offices/1.json
    def destroy
      @bank_office = BankOffice.find(params[:id])

      respond_to do |format|
        if @bank_office.destroy
          format.html { redirect_to bank_offices_url,
                      notice: (crud_notice('destroyed', @bank_office) + "#{undo_link(@bank_office)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to bank_offices_url, alert: "#{@bank_office.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @bank_office.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      BankOffice.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
