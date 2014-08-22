require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class OrganizationsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /organizations
    # GET /organizations.json
    def index
      manage_filter_state
      @organizations = Organization.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @organizations }
        format.js
      end
    end
  
    # GET /organizations/1
    # GET /organizations/1.json
    def show
      @breadcrumb = 'read'
      @organization = Organization.find(params[:id])
      @companies = @organization.companies
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @organization }
      end
    end
  
    # GET /organizations/new
    # GET /organizations/new.json
    def new
      @breadcrumb = 'create'
      @organization = Organization.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @organization }
      end
    end
  
    # GET /organizations/1/edit
    def edit
      @breadcrumb = 'update'
      @organization = Organization.find(params[:id])
    end
  
    # POST /organizations
    # POST /organizations.json
    def create
      @breadcrumb = 'create'
      @organization = Organization.new(params[:organization])
      @organization.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @organization.save
          format.html { redirect_to @organization, notice: crud_notice('created', @organization) }
          format.json { render json: @organization, status: :created, location: @organization }
        else
          format.html { render action: "new" }
          format.json { render json: @organization.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /organizations/1
    # PUT /organizations/1.json
    def update
      @breadcrumb = 'update'
      @organization = Organization.find(params[:id])
      @organization.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @organization.update_attributes(params[:organization])
          format.html { redirect_to @organization,
                        notice: (crud_notice('updated', @organization) + "#{undo_link(@organization)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @organization.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /organizations/1
    # DELETE /organizations/1.json
    def destroy
      @organization = Organization.find(params[:id])

      respond_to do |format|
        if @organization.destroy
          format.html { redirect_to organizations_url,
                      notice: (crud_notice('destroyed', @organization) + "#{undo_link(@organization)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to organizations_url, alert: "#{@organization.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @organization.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Organization.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
