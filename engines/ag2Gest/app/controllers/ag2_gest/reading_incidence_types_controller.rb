require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingIncidenceTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /reading_incidence_types
    # GET /reading_incidence_types.json
    def index
      manage_filter_state
      @reading_incidence_types = ReadingIncidenceType.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @reading_incidence_types }
        format.js
      end
    end

    # GET /reading_incidence_types/1
    # GET /reading_incidence_types/1.json
    def show
      @breadcrumb = 'read'
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading_incidence_type }
      end
    end

    # GET /reading_incidence_types/new
    # GET /reading_incidence_types/new.json
    def new
      @breadcrumb = 'create'
      @reading_incidence_type = ReadingIncidenceType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading_incidence_type }
      end
    end

    # GET /reading_incidence_types/1/edit
    def edit
      @breadcrumb = 'update'
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
    end

    # POST /reading_incidence_types
    # POST /reading_incidence_types.json
    def create
      @breadcrumb = 'create'
      @reading_incidence_type = ReadingIncidenceType.new(params[:reading_incidence_type])
      @reading_incidence_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @reading_incidence_type.save
          format.html { redirect_to @reading_incidence_type, notice: t('activerecord.attributes.reading_incidence_type.create') }
          format.json { render json: @reading_incidence_type, status: :created, location: @reading_incidence_type }
        else
          format.html { render action: "new" }
          format.json { render json: @reading_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /reading_incidence_types/1
    # PUT /reading_incidence_types/1.json
    def update
      @breadcrumb = 'update'
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
      @reading_incidence_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @reading_incidence_type.update_attributes(params[:reading_incidence_type])
          format.html { redirect_to @reading_incidence_type, notice: t('activerecord.attributes.reading_incidence_type.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /reading_incidence_types/1
    # DELETE /reading_incidence_types/1.json
    def destroy
      @reading_incidence_type = ReadingIncidenceType.find(params[:id])
      @reading_incidence_type.destroy

      respond_to do |format|
        format.html { redirect_to reading_incidence_types_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      ReadingIncidenceType.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
