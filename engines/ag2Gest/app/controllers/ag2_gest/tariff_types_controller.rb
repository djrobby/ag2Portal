require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class TariffTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /tariff_types
    # GET /tariff_types.json
    def index
      manage_filter_state
      @tariff_types = TariffType.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tariff_types }
        format.js
      end
    end

    # GET /tariff_types/1
    # GET /tariff_types/1.json
    def show
      @breadcrumb = 'read'
      @tariff_type = TariffType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tariff_type }
      end
    end

    # GET /tariff_types/new
    # GET /tariff_types/new.json
    def new
      @breadcrumb = 'create'
      @tariff_type = TariffType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tariff_type }
      end
    end

    # GET /tariff_types/1/edit
    def edit
      @breadcrumb = 'update'
      @tariff_type = TariffType.find(params[:id])
    end

    # POST /tariff_types
    # POST /tariff_types.json
    def create
      @breadcrumb = 'create'
      @tariff_type = TariffType.new(params[:tariff_type])
      @tariff_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @tariff_type.save
          format.html { redirect_to @tariff_type, notice: t('activerecord.attributes.tariff_type.create') }
          format.json { render json: @tariff_type, status: :created, location: @tariff_type }
        else
          format.html { render action: "new" }
          format.json { render json: @tariff_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /tariff_types/1
    # PUT /tariff_types/1.json
    def update
      @breadcrumb = 'update'
      @tariff_type = TariffType.find(params[:id])
      @tariff_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @tariff_type.update_attributes(params[:tariff_type])
          format.html { redirect_to @tariff_type, notice: t('activerecord.attributes.tariff_type.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @tariff_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tariff_types/1
    # DELETE /tariff_types/1.json
    def destroy
      @tariff_type = TariffType.find(params[:id])
      @tariff_type.destroy

      respond_to do |format|
        format.html { redirect_to tariff_types_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      TariffType.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
