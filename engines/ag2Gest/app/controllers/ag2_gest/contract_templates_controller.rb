require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractTemplatesController < ApplicationController

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_country_textfield_from_region,
                                               :update_region_textfield_from_province
                                               ]

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

    # GET /contract_templates
    # GET /contract_templates.json
    def index
      @contract_templates = ContractTemplate.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contract_templates }
        format.js
      end
    end
  
    # GET /contract_templates/1
    # GET /contract_templates/1.json
    def show
      @breadcrumb = 'read'
      @contract_template = ContractTemplate.find(params[:id])
      @contract_template_terms = @contract_template.contract_template_terms.paginate(:page => params[:page], :per_page => per_page).order('term_no')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contract_template }
      end
    end
  
    # GET /contract_templates/new
    # GET /contract_templates/new.json
    def new
      @breadcrumb = 'create'
      @contract_template = ContractTemplate.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contract_template }
      end
    end
  
    # GET /contract_templates/1/edit
    def edit
      @breadcrumb = 'update'
      @contract_template = ContractTemplate.find(params[:id])
    end
  
    # POST /contract_templates
    # POST /contract_templates.json
    def create
      @breadcrumb = 'create'
      @contract_template = ContractTemplate.new(params[:contract_template])
      @contract_template.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @contract_template.save
          format.html { redirect_to @contract_template, notice: crud_notice('created', @contract_template) }
          format.json { render json: @contract_template, status: :created, location: @contract_template }
        else
          format.html { render action: "new" }
          format.json { render json: @contract_template.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contract_templates/1
    # PUT /contract_templates/1.json
    def update
      @breadcrumb = 'update'
      @contract_template = ContractTemplate.find(params[:id])
      @contract_template.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contract_template.update_attributes(params[:contract_template])
          format.html { redirect_to @contract_template,
                        notice: (crud_notice('updated', @contract_template) + "#{undo_link(@contract_template)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contract_template.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /contract_templates/1
    # DELETE /contract_templates/1.json
    def destroy
      @contract_template = ContractTemplate.find(params[:id])

      respond_to do |format|
        if @contract_template.destroy
          format.html { redirect_to contract_templates_url,
                      notice: (crud_notice('destroyed', @contract_template) + "#{undo_link(@contract_template)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to contract_templates_url, alert: "#{@contract_template.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @contract_template.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ContractTemplate.column_names.include?(params[:sort]) ? params[:sort] : "name"
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