require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class ActivitiesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /activities
    # GET /activities.json
    def index
      manage_filter_state
      @activities = Activity.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @activities }
        format.js
      end
    end
  
    # GET /activities/1
    # GET /activities/1.json
    def show
      @breadcrumb = 'read'
      @activity = Activity.find(params[:id])
      @suppliers = @activity.suppliers.paginate(:page => params[:page], :per_page => per_page).order('supplier_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @activity }
        format.js
      end
    end
  
    # GET /activities/new
    # GET /activities/new.json
    def new
      @breadcrumb = 'create'
      @activity = Activity.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @activity }
      end
    end
  
    # GET /activities/1/edit
    def edit
      @breadcrumb = 'update'
      @activity = Activity.find(params[:id])
    end
  
    # POST /activities
    # POST /activities.json
    def create
      @breadcrumb = 'create'
      @activity = Activity.new(params[:activity])
      @activity.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @activity.save
          format.html { redirect_to @activity, notice: crud_notice('created', @activity) }
          format.json { render json: @activity, status: :created, location: @activity }
        else
          format.html { render action: "new" }
          format.json { render json: @activity.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /activities/1
    # PUT /activities/1.json
    def update
      @breadcrumb = 'update'
      @activity = Activity.find(params[:id])
      @activity.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @activity.update_attributes(params[:activity])
          format.html { redirect_to @activity,
                        notice: (crud_notice('updated', @activity) + "#{undo_link(@activity)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @activity.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /activities/1
    # DELETE /activities/1.json
    def destroy
      @activity = Activity.find(params[:id])

      respond_to do |format|
        if @activity.destroy
          format.html { redirect_to activities_url,
                      notice: (crud_notice('destroyed', @activity) + "#{undo_link(@activity)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to activities_url, alert: "#{@activity.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @activity.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Activity.column_names.include?(params[:sort]) ? params[:sort] : "description"
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
