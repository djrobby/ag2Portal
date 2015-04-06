require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class RatioGroupsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /ratio_groups
    # GET /ratio_groups.json
    def index
      manage_filter_state
      if session[:organization] != '0'
        @ratio_groups = RatioGroup.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @ratio_groups = RatioGroup.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ratio_groups }
        format.js
      end
    end
  
    # GET /ratio_groups/1
    # GET /ratio_groups/1.json
    def show
      @breadcrumb = 'read'
      @ratio_group = RatioGroup.find(params[:id])
      @ratios = @ratio_group.ratios.paginate(:page => params[:page], :per_page => per_page).order(:code)
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ratio_group }
      end
    end
  
    # GET /ratio_groups/new
    # GET /ratio_groups/new.json
    def new
      @breadcrumb = 'create'
      @ratio_group = RatioGroup.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ratio_group }
      end
    end
  
    # GET /ratio_groups/1/edit
    def edit
      @breadcrumb = 'update'
      @ratio_group = RatioGroup.find(params[:id])
    end
  
    # POST /ratio_groups
    # POST /ratio_groups.json
    def create
      @breadcrumb = 'create'
      @ratio_group = RatioGroup.new(params[:ratio_group])
      @ratio_group.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @ratio_group.save
          format.html { redirect_to @ratio_group, notice: crud_notice('created', @ratio_group) }
          format.json { render json: @ratio_group, status: :created, location: @ratio_group }
        else
          format.html { render action: "new" }
          format.json { render json: @ratio_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /ratio_groups/1
    # PUT /ratio_groups/1.json
    def update
      @breadcrumb = 'update'
      @ratio_group = RatioGroup.find(params[:id])
      @ratio_group.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @ratio_group.update_attributes(params[:ratio_group])
          format.html { redirect_to @ratio_group,
                        notice: (crud_notice('updated', @ratio_group) + "#{undo_link(@ratio_group)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ratio_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /ratio_groups/1
    # DELETE /ratio_groups/1.json
    def destroy
      @ratio_group = RatioGroup.find(params[:id])

      respond_to do |format|
        if @ratio_group.destroy
          format.html { redirect_to ratio_groups_url,
                      notice: (crud_notice('destroyed', @ratio_group) + "#{undo_link(@ratio_group)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to ratio_groups_url, alert: "#{@ratio_group.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @ratio_group.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      RatioGroup.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
