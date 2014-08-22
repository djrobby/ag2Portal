require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class SharedContactsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_country_textfield_from_region,
                                               :update_region_textfield_from_province]
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

    #
    # Default Methods
    #
    # GET /shared_contacts
    # GET /shared_contacts.json
    def index
      manage_filter_state
      letter = params[:letter]
      if !session[:organization]
        init_oco
      end

      @search = SharedContact.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          any_of do
            with(:last_name).starting_with(letter)
            with(:company).starting_with(letter)
          end
        end
        order_by :company, :asc
        order_by :last_name, :asc
        order_by :first_name, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @shared_contacts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @shared_contacts }
        format.js
      end
    end

    # GET /shared_contacts/1
    # GET /shared_contacts/1.json
    def show
      @breadcrumb = 'read'
      @shared_contact = SharedContact.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @shared_contact }
      end
    end

    # GET /shared_contacts/new
    # GET /shared_contacts/new.json
    def new
      @breadcrumb = 'create'
      @shared_contact = SharedContact.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @shared_contact }
      end
    end

    # GET /shared_contacts/1/edit
    def edit
      @breadcrumb = 'update'
      @shared_contact = SharedContact.find(params[:id])
    end

    # POST /shared_contacts
    # POST /shared_contacts.json
    def create
      @breadcrumb = 'create'
      @shared_contact = SharedContact.new(params[:shared_contact])
      @shared_contact.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @shared_contact.save
          format.html { redirect_to @shared_contact, notice: crud_notice('created', @shared_contact) }
          format.json { render json: @shared_contact, status: :created, location: @shared_contact }
        else
          format.html { render action: "new" }
          format.json { render json: @shared_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /shared_contacts/1
    # PUT /shared_contacts/1.json
    def update
      @breadcrumb = 'update'
      @shared_contact = SharedContact.find(params[:id])
      @shared_contact.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @shared_contact.update_attributes(params[:shared_contact])
          format.html { redirect_to @shared_contact,
                        notice: (crud_notice('updated', @shared_contact) + "#{undo_link(@shared_contact)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @shared_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /shared_contacts/1
    # DELETE /shared_contacts/1.json
    def destroy
      @shared_contact = SharedContact.find(params[:id])
      @shared_contact.destroy

      respond_to do |format|
        format.html { redirect_to shared_contacts_url,
                      notice: (crud_notice('destroyed', @shared_contact) + "#{undo_link(@shared_contact)}").html_safe }
        format.json { head :no_content }
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
