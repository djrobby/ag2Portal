require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CountriesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /countries
    # GET /countries.json
    def index
      manage_filter_state
      @countries = Country.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @countries }
        format.js
      end
    end

    # GET /countries/1
    # GET /countries/1.json
    def show
      @breadcrumb = 'read'
      @country = Country.find(params[:id])
      @regions = @country.regions.order("name")

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @country }
      end
    end

    # GET /countries/new
    # GET /countries/new.json
    def new
      @breadcrumb = 'create'
      @country = Country.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @country }
      end
    end

    # GET /countries/1/edit
    def edit
      @breadcrumb = 'update'
      @country = Country.find(params[:id])
    end

    # POST /countries
    # POST /countries.json
    def create
      @breadcrumb = 'create'
      @country = Country.new(params[:country])
      @country.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @country.save
          format.html { redirect_to @country, notice: crud_notice('created', @country) }
          format.json { render json: @country, status: :created, location: @country }
        else
          format.html { render action: "new" }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /countries/1
    # PUT /countries/1.json
    def update
      @breadcrumb = 'update'
      @country = Country.find(params[:id])
      @country.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @country.update_attributes(params[:country])
          format.html { redirect_to @country,
                        notice: (crud_notice('updated', @country) + "#{undo_link(@country)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /countries/1
    # DELETE /countries/1.json
    def destroy
      @country = Country.find(params[:id])

      respond_to do |format|
        if @country.destroy
          format.html { redirect_to countries_url,
                      notice: (crud_notice('destroyed', @country) + "#{undo_link(@country)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to countries_url, alert: "#{@country.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Country.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
