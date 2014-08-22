require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class RolesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /roles
    # GET /roles.json
    def index
      manage_filter_state
      @roles = Role.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @roles }
        format.js
      end
    end

    # GET /roles/1
    # GET /roles/1.json
    def show
      @breadcrumb = 'read'
      @role = Role.find(params[:id])
      @users = @role.users

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @role }
      end
    end

    # GET /roles/new
    # GET /roles/new.json
    def new
      @breadcrumb = 'create'
      @role = Role.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @role }
      end
    end

    # GET /roles/1/edit
    def edit
      @breadcrumb = 'update'
      @role = Role.find(params[:id])
    end

    # POST /roles
    # POST /roles.json
    def create
      @breadcrumb = 'create'
      @role = Role.new(params[:role])
      @role.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @role.save
          format.html { redirect_to @role, notice: crud_notice('created', @role) }
          format.json { render json: @role, status: :created, location: @role }
        else
          format.html { render action: "new" }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /roles/1
    # PUT /roles/1.json
    def update
      @breadcrumb = 'update'
      @role = Role.find(params[:id])
      @role.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @role.update_attributes(params[:role])
          format.html { redirect_to @role,
                        notice: (crud_notice('updated', @role) + "#{undo_link(@role)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /roles/1
    # DELETE /roles/1.json
    def destroy
      @role = Role.find(params[:id])

      respond_to do |format|
        if @role.destroy
          format.html { redirect_to roles_url,
                      notice: (crud_notice('destroyed', @role) + "#{undo_link(@role)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to roles_url, alert: "#{@role.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Role.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
