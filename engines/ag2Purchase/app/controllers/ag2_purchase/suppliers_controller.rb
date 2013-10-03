require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SuppliersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_country_textfield_from_region,
                                               :update_region_textfield_from_province,
                                               :update_code_textfield,
                                               :validate_fiscal_id_textfield]
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
    def update_code_textfield
      activity = params[:id]
      code = ''

      # Builds code, if possible
      if activity == '$'
        code = '$err'
      else
        activity = activity.split(",").first
        activity = activity.rjust(4, '0')
        last_supplier_code = Supplier.where("supplier_code LIKE ?", "#{activity}%").order('supplier_code').maximum('supplier_code')
        if last_supplier_code.nil?
          code = activity + '-00001'
        else
          last_supplier_code = last_supplier_code.split("-").last.to_i + 1
          code = activity + '-' + last_supplier_code.rjust(5, '0')
        end
      end
      @json_data = { "code" => code }

      respond_to do |format|
        format.html # update_code_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Search Entity
    def validate_fiscal_id_textfield
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

      if params[:id] == '0'
        id = '$err'
        fiscal_id = '$err'
      else
        @entity = Entity.find_by_fiscal_id(params[:id])
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
        end
      end

      @json_data = { "id" => id, "fiscal_id" => fiscal_id,
                     "street_type_id" => street_type_id, "street_name" => street_name,
                     "street_number" => street_number, "building" => building,
                     "floor" => floor, "floor_office" => floor_office, 
                     "zipcode_id" => zipcode_id, "town_id" => town_id,
                     "province_id" => province_id, "region_id" => region_id,
                     "country_id" => country_id, "phone" => phone,
                     "fax" => fax, "cellular" => cellular, "email" => email }

      respond_to do |format|
        format.html # validate_fiscal_id_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /suppliers
    # GET /suppliers.json
    def index
      #@suppliers = Supplier.all
      letter = params[:letter]

      @search = Supplier.search do
        fulltext params[:search]
        order_by :supplier_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      if letter.blank? || letter == "%"
        @suppliers = @search.results
      else
        @suppliers = Supplier.where("name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('supplier_code')
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @suppliers }
      end
    end

    # GET /suppliers/1
    # GET /suppliers/1.json
    def show
      @breadcrumb = 'read'
      @supplier = Supplier.find(params[:id])

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

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier }
      end
    end

    # GET /suppliers/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier = Supplier.find(params[:id])
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
          format.html { render action: "edit" }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /suppliers/1
    # DELETE /suppliers/1.json
    def destroy
      @supplier = Supplier.find(params[:id])
      @supplier.destroy

      respond_to do |format|
        format.html { redirect_to suppliers_url,
                      notice: (crud_notice('destroyed', @supplier) + "#{undo_link(@supplier)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
