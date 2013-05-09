require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class UsersController < ApplicationController
    # GET /users
    # GET /users.json
    def index
      @users = User.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @users }
      end
    end
  
    # GET /users/1
    # GET /users/1.json
    def show
      @breadcrumb = 'read'
      @user = User.find(params[:id])
  
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
          format.html { redirect_to @user, notice: I18n.t('activerecord.successful.messages.created', :model => @user.class.model_name.human) }
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
          format.html { redirect_to @user, notice: I18n.t('activerecord.successful.messages.updated', :model => @user.class.model_name.human) }
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
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    end
  end
end
