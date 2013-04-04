require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CompaniesController < ApplicationController
    # Update hidden province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update hidden province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id }
    
      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /companies
    # GET /companies.json
    def index
      @companies = Company.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @companies }
      end
    end

    # GET /companies/1
    # GET /companies/1.json
    def show
      @breadcrumb = 'read'
      @company = Company.find(params[:id])
      @offices = @company.offices

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @company }
      end
    end

    # GET /companies/new
    # GET /companies/new.json
    def new
      @breadcrumb = 'create'
      @company = Company.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @company }
      end
    end

    # GET /companies/1/edit
    def edit
      @breadcrumb = 'update'
      @company = Company.find(params[:id])
    end

    # POST /companies
    # POST /companies.json
    def create
      @breadcrumb = 'create'
      @company = Company.new(params[:company])

      respond_to do |format|
        if @company.save
          format.html { redirect_to @company, notice: 'Company was successfully created.' }
          format.json { render json: @company, status: :created, location: @company }
        else
          format.html { render action: "new" }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /companies/1
    # PUT /companies/1.json
    def update
      @breadcrumb = 'update'
      @company = Company.find(params[:id])

      respond_to do |format|
        if @company.update_attributes(params[:company])
          format.html { redirect_to @company, notice: 'Company was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /companies/1
    # DELETE /companies/1.json
    def destroy
      @company = Company.find(params[:id])
      @company.destroy

      respond_to do |format|
        format.html { redirect_to companies_url }
        format.json { head :no_content }
      end
    end
  end
end
