require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingIncidencesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /reading_incidences
    # GET /reading_incidences.json
    def index
      manage_filter_state
      @reading_incidences = ReadingIncidence.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @reading_incidences }
      end
    end

    # GET /reading_incidences/1
    # GET /reading_incidences/1.json
    def show
      @breadcrumb = 'read'
      @reading_incidence = ReadingIncidence.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading_incidence }
      end
    end

    # GET /reading_incidences/new
    # GET /reading_incidences/new.json
    def new
      @breadcrumb = 'create'
      @reading_incidence = ReadingIncidence.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading_incidence }
      end
    end

    # GET /reading_incidences/1/edit
    def edit
      @breadcrumb = 'update'
      @reading_incidence = ReadingIncidence.find(params[:id])
    end

    # POST /reading_incidences
    # POST /reading_incidences.json
    def create
      @breadcrumb = 'create'
      @reading_incidence = ReadingIncidence.new(params[:reading_incidence])
      @reading_incidence.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @reading_incidence.save
          format.html { redirect_to @reading_incidence, notice: t('activerecord.attributes.reading_incidence.create') }
          format.json { render json: @reading_incidence, status: :created, location: @reading_incidence }
        else
          format.html { render action: "new" }
          format.json { render json: @reading_incidence.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /reading_incidences/1
    # PUT /reading_incidences/1.json
    def update
      @reading_incidence = ReadingIncidence.find(params[:id])
      @reading_incidence.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @reading_incidence.update_attributes(params[:reading_incidence])
          format.html { redirect_to @reading_incidence, notice: t('activerecord.attributes.reading_incidence.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading_incidence.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /reading_incidences/1
    # DELETE /reading_incidences/1.json
    def destroy
      @reading_incidence = ReadingIncidence.find(params[:id])
      @reading_incidence.destroy

      respond_to do |format|
        format.html { redirect_to reading_incidences_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      ReadingIncidence.column_names.include?(params[:sort]) ? params[:sort] : "reading_incidences"
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
