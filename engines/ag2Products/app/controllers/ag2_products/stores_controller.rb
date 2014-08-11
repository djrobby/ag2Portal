require_dependency "ag2_products/application_controller"

module Ag2Products
  class StoresController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:st_update_company_textfield_from_office,
                                               :st_update_company_and_office_textfields_from_organization]
    # Helper methods for sorting
    helper_method :sort_column

    # Update company text field at view from office select
    def st_update_company_textfield_from_office
      office = params[:id]
      @company = 0
      if office != '0'
        @office = Office.find(office)
        @company = @office.blank? ? 0 : @office.company
      end

      respond_to do |format|
        format.html # pr_update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end
    
    # Update company & office text fields at view from organization select
    def st_update_company_and_office_textfields_from_organization
      organization = params[:id]
      if organization != '0'
        @organization = Organization.find(organization)
        @companies = @organization.blank? ? companies_dropdown : @organization.companies.order(:name)
        @offices = @organization.blank? ? offices_dropdown : Office.joins(:company).where(companies: { organization_id: organization }).order(:name)
        @suppliers = @organization.blank? ? companies_dropdown : @organization.suppliers.order(:name)
      else
        @companies = companies_dropdown
        @offices = offices_dropdown
        @suppliers = suppliers_dropdown
      end
      @offices_dropdown = []
      @offices.each do |i|
        @offices_dropdown = @offices_dropdown << [i.id, i.name, i.company.name] 
      end
      @json_data = { "companies" => @companies, "offices" => @offices_dropdown, "suppliers" => @suppliers }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /stores
    # GET /stores.json
    def index
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @stores = Store.where("organization_id = ?", "#{session[:organization]}").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @stores = Store.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @stores }
      end
    end
  
    # GET /stores/1
    # GET /stores/1.json
    def show
      reset_stock_prices_filter
      @breadcrumb = 'read'
      @store = Store.find(params[:id])
      @stocks = @store.stocks.paginate(:page => params[:page], :per_page => per_page).order('product_id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @store }
      end
    end
  
    # GET /stores/new
    # GET /stores/new.json
    def new
      @breadcrumb = 'create'
      @store = Store.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @suppliers = suppliers_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @store }
      end
    end
  
    # GET /stores/1/edit
    def edit
      @breadcrumb = 'update'
      @store = Store.find(params[:id])
      @companies = @store.organization.blank? ? companies_dropdown : companies_dropdown_edit(@store.organization)
      @offices = @store.organization.blank? ? offices_dropdown : offices_dropdown_edit(@store.organization_id)
      @suppliers = @store.organization.blank? ? suppliers_dropdown : suppliers_dropdown_edit(@store.organization)
    end
  
    # POST /stores
    # POST /stores.json
    def create
      @breadcrumb = 'create'
      @store = Store.new(params[:store])
      @store.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @store.save
          format.html { redirect_to @store, notice: crud_notice('created', @store) }
          format.json { render json: @store, status: :created, location: @store }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          format.html { render action: "new" }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /stores/1
    # PUT /stores/1.json
    def update
      @breadcrumb = 'update'
      @store = Store.find(params[:id])
      @store.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @store.update_attributes(params[:store])
          format.html { redirect_to @store,
                        notice: (crud_notice('updated', @store) + "#{undo_link(@store)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @store.organization.blank? ? companies_dropdown : companies_dropdown_edit(@store.organization)
          @offices = @store.organization.blank? ? offices_dropdown : offices_dropdown_edit(@store.organization_id)
          format.html { render action: "edit" }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /stores/1
    # DELETE /stores/1.json
    def destroy
      @store = Store.find(params[:id])
  
      respond_to do |format|
        if @store.destroy
          format.html { redirect_to stores_url,
                      notice: (crud_notice('destroyed', @store) + "#{undo_link(@store)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to stores_url, alert: "#{@store.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Store.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def reset_stock_prices_filter
      session[:Products] = nil
      session[:Stores] = nil      
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

    def suppliers_dropdown
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:name) : Supplier.order(:name)
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

    def suppliers_dropdown_edit(_organization)
      if session[:organization] != '0'
        _suppliers = Supplier.where(organization_id: session[:organization].to_i).order(:name)
      else
        _suppliers = _organization.suppliers.order(:name)
      end
    end

    def offices_by_company(_company)
      _offices = Office.where(company_id: _company).order(:name)      
    end
  end
end
