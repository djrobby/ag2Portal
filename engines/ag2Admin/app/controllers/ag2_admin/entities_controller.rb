require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class EntitiesController < ApplicationController
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
    # GET /entities
    # GET /entities.json
    def index
      letter = params[:letter]

      @search = Entity.search do
        fulltext params[:search]
        order_by :fiscal_id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      if letter.blank? || letter == "%"
        @entities = @search.results
      else
        @entities = Entity.where("last_name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('fiscal_id')
        if @entities.count == 0
          @entities = Entity.where("company LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('fiscal_id')
        end
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @suppliers }
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def show
      @breadcrumb = 'read'
      @entity = Entity.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @entity }
      end
    end

    # GET /entities/new
    # GET /entities/new.json
    def new
      @breadcrumb = 'create'
      @entity = Entity.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @entity }
      end
    end

    # GET /entities/1/edit
    def edit
      @breadcrumb = 'update'
      @entity = Entity.find(params[:id])
    end

    # POST /entities
    # POST /entities.json
    def create
      @breadcrumb = 'create'
      @entity = Entity.new(params[:entity])
      @entity.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @entity.save
          format.html { redirect_to @entity, notice: crud_notice('created', @entity) }
          format.json { render json: @entity, status: :created, location: @entity }
        else
          format.html { render action: "new" }
          format.json { render json: @entity.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /entities/1
    # PUT /entities/1.json
    def update
      @breadcrumb = 'update'
      @entity = Entity.find(params[:id])
      @entity.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @entity.update_attributes(params[:entity])
          format.html { redirect_to @entity,
                        notice: (crud_notice('updated', @entity) + "#{undo_link(@entity)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @entity.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /entities/1
    # DELETE /entities/1.json
    def destroy
      @entity = Entity.find(params[:id])

      respond_to do |format|
        if @entity.destroy
          format.html { redirect_to entities_url,
                      notice: (crud_notice('destroyed', @entity) + "#{undo_link(@entity)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to entities_url, alert: "#{@entity.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @entity.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
