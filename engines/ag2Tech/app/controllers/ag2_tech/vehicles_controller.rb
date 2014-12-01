require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class VehiclesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ve_update_company_textfield_from_office,
                                               :ve_update_company_and_office_textfields_from_organization,
                                               :ve_update_name_textfield_from_product]
    # Helper methods for sorting
    helper_method :sort_column
    
    # Update company text field at view from office select
    def ve_update_company_textfield_from_office
      office = params[:id]
      @company = 0
      if office != '0'
        @office = Office.find(office)
        @company = @office.blank? ? 0 : @office.company
      end
      render json: @company
    end
    
    # Update company & office text fields at view from organization select
    def ve_update_company_and_office_textfields_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? companies_dropdown : @organization.companies.order(:name)
        @offices = @organization.blank? ? offices_dropdown : Office.joins(:company).where(companies: { organization_id: organization }).order(:name)
        @products = @organization.blank? ? products_dropdown : @organization.products.order(:product_code)
      else
        @companies = companies_dropdown
        @offices = offices_dropdown
        @products = products_dropdown
      end
      @offices_dropdown = []
      @offices.each do |i|
        @offices_dropdown = @offices_dropdown << [i.id, i.name, i.company.name] 
      end
      @json_data = { "companies" => @companies, "offices" => @offices_dropdown, "products" => @products }
      render json: @json_data
    end
    
    # Update name text field at view from product select
    def ve_update_name_textfield_from_product
      product = params[:product]
      description = ""
      cost = 0
      manufacturer = ""
      if product != '0'
        @product = Product.find(product)
        # Assignment
        description = @product.main_description[0,40]
        cost = @product.reference_price
        manufacturer = @product.manufacturer.name rescue ""
      end
      # Format numbers
      cost = number_with_precision(cost.round(4), precision: 4)
      # Setup JSON
      @json_data = { "description" => description, "cost" => cost.to_s, "manufacturer" => manufacturer }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /vehicles
    # GET /vehicles.json
    def index
      manage_filter_state
      # OCO
      init_oco if !session[:organization]

      @search = Vehicle.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        order_by :registration, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @vehicles = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @vehicles }
        format.js
      end
    end
  
    # GET /vehicles/1
    # GET /vehicles/1.json
    def show
      @breadcrumb = 'read'
      @vehicle = Vehicle.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @vehicle }
      end
    end
  
    # GET /vehicles/new
    # GET /vehicles/new.json
    def new
      @breadcrumb = 'create'
      @vehicle = Vehicle.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @products = products_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @vehicle }
      end
    end
  
    # GET /vehicles/1/edit
    def edit
      @breadcrumb = 'update'
      @vehicle = Vehicle.find(params[:id])
      @companies = @vehicle.organization.blank? ? companies_dropdown : companies_dropdown_edit(@vehicle.organization)
      @offices = @vehicle.organization.blank? ? offices_dropdown : offices_dropdown_edit(@vehicle.organization_id)
      @products = @vehicle.organization.blank? ? products_dropdown : @vehicle.organization.products(:product_code)
    end
  
    # POST /vehicles
    # POST /vehicles.json
    def create
      @breadcrumb = 'create'
      @vehicle = Vehicle.new(params[:vehicle])
      @vehicle.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @vehicle.save
          format.html { redirect_to @vehicle, notice: crud_notice('created', @vehicle) }
          format.json { render json: @vehicle, status: :created, location: @vehicle }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          @products = products_dropdown
          format.html { render action: "new" }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /vehicles/1
    # PUT /vehicles/1.json
    def update
      @breadcrumb = 'update'
      @vehicle = Vehicle.find(params[:id])
      @vehicle.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @vehicle.update_attributes(params[:vehicle])
          format.html { redirect_to @vehicle,
                        notice: (crud_notice('updated', @vehicle) + "#{undo_link(@vehicle)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @vehicle.organization.blank? ? companies_dropdown : companies_dropdown_edit(@vehicle.organization)
          @offices = @vehicle.organization.blank? ? offices_dropdown : offices_dropdown_edit(@vehicle.organization_id)
          @products = @vehicle.organization.blank? ? products_dropdown : @vehicle.organization.products(:product_code)
          format.html { render action: "edit" }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /vehicles/1
    # DELETE /vehicles/1.json
    def destroy
      @vehicle = Vehicle.find(params[:id])

      respond_to do |format|
        if @vehicle.destroy
          format.html { redirect_to vehicles_url,
                      notice: (crud_notice('destroyed', @vehicle) + "#{undo_link(@vehicle)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to vehicles_url, alert: "#{@vehicle.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @vehicle.errors, status: :unprocessable_entity }
        end
      end
    end

    private

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
      _offices = Office.where(company_id: _company).order(:name)      
    end

    def products_dropdown
      session[:organization] != '0' ? Product.where(organization_id: session[:organization].to_i).order(:product_code) : Product.order(:product_code)
    end    

    # Sort by column
    def sort_column
      Vehicle.column_names.include?(params[:sort]) ? params[:sort] : "registration"
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
    end
  end
end
