require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterBrandsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_brands
    # GET /meter_brands.json
    def index
      manage_filter_state
      @meter_brands = MeterBrand.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_brands }
        format.js
      end
    end

    # GET /meter_brands/1
    # GET /meter_brands/1.json
    def show

      @breadcrumb = 'read'
      @meter_brand = MeterBrand.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_brand }
      end
    end

    # GET /meter_brands/new
    # GET /meter_brands/new.json
    def new
      @breadcrumb = 'create'
      @meter_brand = MeterBrand.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_brand }
      end
    end

    # GET /meter_brands/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_brand = MeterBrand.find(params[:id])
    end

    # POST /meter_brands
    # POST /meter_brands.json
    def create
      @breadcrumb = 'create'
      @meter_brand = MeterBrand.new(params[:meter_brand])
      @meter_brand.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_brand.save
          format.html { redirect_to @meter_brand, notice: t('activerecord.attributes.meter_brand.create') }
          format.json { render json: @meter_brand, status: :created, location: @meter_brand }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_brand.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meter_brands/1
    # PUT /meter_brands/1.json
    def update
      @breadcrumb = 'update'
      @meter_brand = MeterBrand.find(params[:id])
      @meter_brand.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_brand.update_attributes(params[:meter_brand])
          format.html { redirect_to @meter_brand,
                        notice: (crud_notice('updated', @meter_brand) + "#{undo_link(@meter_brand)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_brand.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meter_brands/1
    # DELETE /meter_brands/1.json
    def destroy
      @meter_brand = MeterBrand.find(params[:id])

      respond_to do |format|
        if @meter_brand.destroy
          format.html { redirect_to meter_brands_url,
                      notice: (crud_notice('destroyed', @meter_brand) + "#{undo_link(@meter_brand)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meter_brands_url, alert: "#{@meter_brand.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter_brand.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      MeterBrand.column_names.include?(params[:sort]) ? params[:sort] : "brand"
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
