require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class StreetDirectoriesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /street_directories
    # GET /street_directories.json
    def index
      manage_filter_state

      #@street_directories = StreetDirectory.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      @street_directories = StreetDirectory.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @street_directories }
        format.js
      end
    end

    # GET /street_directories/1
    # GET /street_directories/1.json
    def show
      @breadcrumb = 'read'
      @street_directory = StreetDirectory.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @street_directory }
      end
    end

    # GET /street_directories/new
    # GET /street_directories/new.json
    def new
      @breadcrumb = 'create'
      @street_directory = StreetDirectory.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @street_directory }
      end
    end

    # GET /street_directories/1/edit
    def edit
      @breadcrumb = 'update'
      @street_directory = StreetDirectory.find(params[:id])
    end

    # POST /street_directories
    # POST /street_directories.json
    def create
      @breadcrumb = 'create'
      @street_directory = StreetDirectory.new(params[:street_directory])
      @street_directory.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @street_directory.save
          format.html { redirect_to @street_directory, notice: t('activerecord.attributes.street_directory.create') }
          format.json { render json: @street_directory, status: :created, location: @street_directory }
        else
          format.html { render action: "new" }
          format.json { render json: @street_directory.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /street_directories/1
    # PUT /street_directories/1.json
    def update
      @breadcrumb = 'update'
      @street_directory = StreetDirectory.find(params[:id])
      @street_directory.updated_by = current_user.id if !current_user.nil?
      
      respond_to do |format|
        if @street_directory.update_attributes(params[:street_directory])
          format.html { redirect_to @street_directory, notice: t('activerecord.attributes.street_directory.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @street_directory.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /street_directories/1
    # DELETE /street_directories/1.json
    def destroy
      @street_directory = StreetDirectory.find(params[:id])
      @street_directory.destroy

      respond_to do |format|
        format.html { redirect_to street_directories_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      StreetDirectory.column_names.include?(params[:sort]) ? params[:sort] : "street_name"
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
