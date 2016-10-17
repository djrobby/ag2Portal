require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillingPeriodsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /billing_periods
    # GET /billing_periods.json
    def index
      manage_filter_state

      @billing_periods = BillingPeriod.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billing_periods }
        format.js
      end
    end

    # GET /billing_periods/1
    # GET /billing_periods/1.json
    def show

      @breadcrumb = 'read'
      @billing_period = BillingPeriod.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billing_period }
      end
    end

    # GET /billing_periods/new
    # GET /billing_periods/new.json
    def new

      #if session[:organization] != '0'
        #@projects = Organization.find(session[:organization]).projects.order('name') #Array de projects
      #elsif session[:company] != '0'
        #@projects = Company.find(session[:company]).projects.order('name') #Array de projects
      #elsif session[:office] != '0'
        #@projects = Office.find(session[:office]).projects.order('name') #Array de projects
      #end

      @breadcrumb = 'create'
      @billing_period = BillingPeriod.new
      @projects = current_projects.blank? ? Project.all : current_projects

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billing_period }
      end

    end

    # GET /billing_periods/1/edit
    def edit
      @breadcrumb = 'update'
      @projects = current_projects.blank? ? Project.all : current_projects
      @billing_period = BillingPeriod.find(params[:id])
    end

    # POST /billing_periods
    # POST /billing_periods.json
    def create

      @breadcrumb = 'create'
      @billing_period = BillingPeriod.new(params[:billing_period])
      @billing_period.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billing_period.save
          format.html { redirect_to @billing_period, notice: t('activerecord.attributes.billing_period.create') }
          format.json { render json: @billing_period, status: :created, location: @billing_period }
        else
          format.html { render action: "new" }
          format.json { render json: @billing_period.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /billing_periods/1
    # PUT /billing_periods/1.json
    def update
      @breadcrumb = 'update'
      @billing_period = BillingPeriod.find(params[:id])
      @billing_period.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billing_period.update_attributes(params[:billing_period])
          format.html { redirect_to @billing_period, notice: t('activerecord.attributes.billing_period.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billing_period.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /billing_periods/1
    # DELETE /billing_periods/1.json
    def destroy
      @billing_period = BillingPeriod.find(params[:id])
      @billing_period.destroy

      respond_to do |format|
        format.html { redirect_to billing_periods_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      BillingPeriod.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
