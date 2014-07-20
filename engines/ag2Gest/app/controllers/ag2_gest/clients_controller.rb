require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ClientsController < ApplicationController
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

    # Update client code at view (generate_code_btn)
    def update_code_textfield
      organization = '0001'
      code = ''

      # Builds code, if possible
      last_client_code = Client.where("client_code LIKE ?", "#{organization}%").order('client_code').maximum('client_code')
      if last_client_code.nil?
        code = organization + '0000001'
      else
        last_client_code = last_client_code[4..10].to_i + 1
        code = organization + last_client_code.to_s.rjust(6, '0')
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

      @json_data = { "id" => id, "fiscal_id" => fiscal_id, "name" => name,
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
      manage_filter_state
      letter = params[:letter]

      @search = Client.search do
        fulltext params[:search]
        if !letter.blank? && letter != "%"
          with(:name).starting_with(letter)
        end
        order_by :client_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @clients = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @clients }
      end
    end
  
    # GET /clients/1
    # GET /clients/1.json
    def show
      @breadcrumb = 'read'
      @client = Client.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @client }
      end
    end
  
    # GET /clients/new
    # GET /clients/new.json
    def new
      @breadcrumb = 'create'
      @client = Client.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @client }
      end
    end
  
    # GET /clients/1/edit
    def edit
      @breadcrumb = 'update'
      @client = Client.find(params[:id])
    end
  
    # POST /clients
    # POST /clients.json
    def create
      @breadcrumb = 'create'
      @client = Client.new(params[:client])
      @client.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @client.save
          format.html { redirect_to @client, notice: crud_notice('created', @client) }
          format.json { render json: @client, status: :created, location: @client }
        else
          format.html { render action: "new" }
          format.json { render json: @client.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /clients/1
    # PUT /clients/1.json
    def update
      @breadcrumb = 'update'
      @client = Client.find(params[:id])
      @client.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @client.update_attributes(params[:client])
          format.html { redirect_to @client,
                        notice: (crud_notice('updated', @client) + "#{undo_link(@client)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @client.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /clients/1
    # DELETE /clients/1.json
    def destroy
      @client = Client.find(params[:id])

      respond_to do |format|
        if @client.destroy
          format.html { redirect_to clients_url,
                      notice: (crud_notice('destroyed', @client) + "#{undo_link(@client)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to clients_url, alert: "#{@client.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @client.errors, status: :unprocessable_entity }
        end
      end
    end

    private

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
  end
end
