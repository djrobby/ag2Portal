require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class UsersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # Update company & organization from office select
    def update_company_organization_from_office
      company_id = 0;
      organization_id = 0;
      
      if params[:box] != '0'
        office = Office.find(params[:box])
        if !office.nil?
          company_id = office.company_id
          organization_id = office.company.organization_id
        end
      end

      @json_data = { "company_id" => company_id, "organization_id" => organization_id }

      respond_to do |format|
        format.html # update_company_organization_from_office.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update organization from company select
    def update_organization_from_company
      organization_id = 0;
      
      if params[:box] != '0'
        company = Company.find(params[:box])
        if !company.nil?
          organization_id = company.organization_id
        end
      end

      @json_data = { "organization_id" => organization_id }

      respond_to do |format|
        format.html # update_company_organization_from_office.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end
    
    #
    # Default Methods
    #
    # GET /users
    # GET /users.json
    def index
      manage_filter_state
      letter = params[:letter]
      if letter.blank? || letter == "%"
        @users = User.paginate(:page => params[:page], :per_page => slow_per_page).order(sort_column + ' ' + sort_direction)
      else
        @users = User.where("name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => slow_per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @users }
        format.js
      end
    end

    # GET /users/1
    # GET /users/1.json
    def show
      @breadcrumb = 'read'
      @user = User.find(params[:id])
      @roles = @user.roles.order('name')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    end

    # GET /users/new
    # GET /users/new.json
    def new
      @breadcrumb = 'create'
      @user = User.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @user }
      end
    end

    # GET /users/1/edit
    def edit
      @breadcrumb = 'update'
      @user = User.find(params[:id])
    end

    # POST /users
    # POST /users.json
    def create
      @breadcrumb = 'create'
      @user = User.new(params[:user])
      @user.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: crud_notice('created', @user) }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render action: "new" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /users/1
    # PUT /users/1.json
    def update
      @breadcrumb = 'update'
      @user = User.find(params[:id])
      @user.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
      #if @user.update_attributes(params[:user], :as => :admin)
        if @user.update_attributes(params[:user])
          # format.html { redirect_to @user, notice: crud_notice('updated', @user) }
          format.html { redirect_to params[:referrer], notice: crud_notice('updated', @user) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url, notice: crud_notice('destroyed', @user) }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    private

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
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end
  end
end
