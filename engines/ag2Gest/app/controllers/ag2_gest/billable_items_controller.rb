require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class BillableItemsController < ApplicationController
    #include ActionView::Helpers::NumberHelper

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /billable_items
    # GET /billable_items.json
    def index
      manage_filter_state
      if !current_projects_ids.empty?
        @billable_items = BillableItem.find_all_by_project_id(current_projects_ids) #Array de BillableItems
      elsif session[:organization] != '0'
        @companies_ids = Organization.find(session[:organization]).companies.map(&:id) #Array de companies ids
        @billable_items = BillableItem.where(biller_id: @companies_ids) #Array de BillableItems
      elsif session[:company] != '0'
        @billable_items = BillableItem.where(biller_id: session[:company]) #Array de BillableItems
      elsif session[:office] != '0'
        @company_id = Office.find(session[:office]).company #id Company
        @billable_items = BillableItem.where(biller_id: @company_id) #Array de BillableItems
      end
      @billable_items = @billable_items.sort_by(&:"#{sort_column}") unless sort_column == "tariffs_by_caliber"
      @billable_items = @billable_items.reverse if sort_direction == 'desc'
      @billable_items = @billable_items.paginate(:page => params[:page], :per_page => 10)
      #@billable_items.paginate(:page => params[:page], :per_page => 15)
      #@search = @billable_items.search do
        #fulltext params[:search]
        #if session[:organization] != '0'
          #with :project_id, session[:organization]
        #end
        #paginate :page => params[:page], :per_page => 5
      #end
      #@billable_items = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billable_items }
        format.js
      end
    end

    # GET /billable_items/1
    # GET /billable_items/1.json
    def show
      @breadcrumb = 'read'
      @billable_item = BillableItem.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billable_item }
      end
    end

    # GET /billable_items/new
    # GET /billable_items/new.json
    def new
      get_projects


      @breadcrumb = 'create'
      @billable_item = BillableItem.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billable_item }
      end
    end

    # GET /billable_items/1/edit
    def edit
      get_projects

      @breadcrumb = 'update'
      @billable_item = BillableItem.find(params[:id])
    end

    # POST /billable_items
    # POST /billable_items.json
    def create
      get_projects

      @breadcrumb = 'create'
      @billable_item = BillableItem.new(params[:billable_item])
      @billable_item.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billable_item.save
          format.html { redirect_to @billable_item, notice: t('activerecord.attributes.billable_item.create') }
          format.json { render json: @billable_item, status: :created, location: @billable_item }
        else
          format.html { render action: "new" }
          format.json { render json: @billable_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /billable_items/1
    # PUT /billable_items/1.json
    def update
      get_projects

      @breadcrumb = 'update'
      @billable_item = BillableItem.find(params[:id])
      @billable_item.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billable_item.update_attributes(params[:billable_item])
          format.html { redirect_to @billable_item, notice: t('activerecord.attributes.billable_item.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billable_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /billable_items/1
    # DELETE /billable_items/1.json
    def destroy
      @billable_item = BillableItem.find(params[:id])
      @billable_item.destroy

      respond_to do |format|
        format.html { redirect_to billable_items_url }
        format.json { head :no_content }
      end
    end

    private

    def get_projects
      if session[:office] != '0'
        @projects = Office.find(session[:office]).projects.order('name') #Array de projects
        @companies = [Office.find(session[:office]).company] #Company
        @regulations = @projects.map(&:regulations).flatten
      elsif session[:organization] != '0'
        @projects = Organization.find(session[:organization]).projects.order('name') #Array de projects
        @companies = Organization.find(session[:organization]).companies.order('name') #Array de companies
        @regulations = @projects.map(&:regulations).flatten
      elsif session[:company] != '0'
        @projects = Company.find(session[:company]).projects.order('name') #Array de projects
        @companies = Company.find(session[:company]) #Company
        @regulations = @projects.map(&:regulations).flatten
      end
    end

    def sort_column
      BillableItem.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
    end

  end
end
