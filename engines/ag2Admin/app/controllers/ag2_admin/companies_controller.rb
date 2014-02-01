require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CompaniesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode]
    # Helper methods for sorting
    helper_method :sort_column
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
      @companies = Company.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

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
      @company.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @company.save
          format.html { redirect_to @company, notice: crud_notice('created', @company) }
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
      @company.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @company.update_attributes(params[:company])
          format.html { redirect_to @company,
                        notice: (crud_notice('updated', @company) + "#{undo_link(@company)}").html_safe }
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

      respond_to do |format|
        if @company.destroy
          format.html { redirect_to companies_url,
                      notice: (crud_notice('destroyed', @company) + "#{undo_link(@company)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to companies_url, alert: "#{@company.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Company.column_names.include?(params[:sort]) ? params[:sort] : "fiscal_id"
    end
  end
end
