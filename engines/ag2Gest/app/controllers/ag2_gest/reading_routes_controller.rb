require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'


module Ag2Gest
  class ReadingRoutesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :update_office_textfield_from_project]
    helper_method :sort_column


    def update_office_textfield_from_project

      @project = Project.find(params[:id])
      @office_id = @project.office_id
      @json_data = { "office_id" => @office_id }

      respond_to do |format|
        format.html
        format.json { render json: @json_data }
      end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { "office_id" => "" } }
        end
    end

    # GET /reading_routes
    # GET /reading_routes.json
    def index
      manage_filter_state
      if session[:office]
        @reading_routes = ReadingRoute.find_all_by_project_id(current_projects_ids).paginate(:page => params[:page], :per_page => 10)
      else
        @reading_routes = ReadingRoute.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @reading_routes }
        format.js
      end
    end

    # GET /reading_routes/1
    # GET /reading_routes/1.json
    def show
      @breadcrumb = 'read'
      @reading_route = ReadingRoute.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading_route }
      end
    end

    # GET /reading_routes/new
    # GET /reading_routes/new.json
    def new
      @breadcrumb = 'create'
      @reading_route = ReadingRoute.new
      set_projects_offices

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading_route }
      end
    end

    # GET /reading_routes/1/edit
    def edit
      @breadcrumb = 'update'
      @reading_route = ReadingRoute.find(params[:id])
      set_projects_offices
    end

    # POST /reading_routes
    # POST /reading_routes.json
    def create
      @breadcrumb = 'create'
      @reading_route = ReadingRoute.new(params[:reading_route])
      set_projects_offices
      respond_to do |format|
        if @reading_route.save
          format.html { redirect_to @reading_route, notice: t('activerecord.attributes.reading_route.create') }
          format.json { render json: @reading_route, status: :created, location: @reading_route }
        else
          format.html { render action: "new" }
          format.json { render json: @reading_route.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /reading_routes/1
    # PUT /reading_routes/1.json
    def update
      @breadcrumb = 'update'
      @reading_route = ReadingRoute.find(params[:id])
      set_projects_offices

      respond_to do |format|
        if @reading_route.update_attributes(params[:reading_route])
          format.html { redirect_to @reading_route, notice: t('activerecord.attributes.reading_route.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading_route.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /reading_routes/1
    # DELETE /reading_routes/1.json
    def destroy
      @reading_route = ReadingRoute.find(params[:id])
      @reading_route.destroy

      respond_to do |format|
        format.html { redirect_to reading_routes_url }
        format.json { head :no_content }
      end
    end

    private

    def set_projects_offices
      if session[:office]
        @offices = [Office.find(session[:office])]
      elsif session[:company]
        @offices = Company.find(session[:company]).offices
      elsif session[:organization]
        @offices = Organization.find(session[:organization]).companies.map(&:offices).flatten
      else
        @offices = Office.all
      end
      @projects = Project.where(office_id: @offices.map(&:id))
    end

    def sort_column
      ReadingRoute.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
