require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class NotificationsController < ApplicationController
    before_filter :authenticate_user!
    # Helper methods for sorting
    helper_method :sort_column

    # GET /notifications
    # GET /notifications.json
    def index
      @notifications = Notification.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @notifications }
      end
    end
  
    # GET /notifications/1
    # GET /notifications/1.json
    def show
      @breadcrumb = 'read'
      @notification = Notification.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @notification }
      end
    end
  
    # GET /notifications/new
    # GET /notifications/new.json
    def new
      @breadcrumb = 'create'
      @notification = Notification.new
      @tables = ActiveRecord::Base.connection.tables
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @notification }
      end
    end
  
    # GET /notifications/1/edit
    def edit
      @breadcrumb = 'update'
      @notification = Notification.find(params[:id])
      @tables = ActiveRecord::Base.connection.tables
    end
  
    # POST /notifications
    # POST /notifications.json
    def create
      @breadcrumb = 'create'
      @notification = Notification.new(params[:notification])
      @notification.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @notification.save
          format.html { redirect_to @notification, notice: crud_notice('created', @notification) }
          format.json { render json: @notification, status: :created, location: @notification }
        else
          format.html { render action: "new" }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /notifications/1
    # PUT /notifications/1.json
    def update
      @breadcrumb = 'update'
      @notification = Notification.find(params[:id])
      @notification.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @notification.update_attributes(params[:notification])
          format.html { redirect_to @notification,
                        notice: (crud_notice('updated', @notification) + "#{undo_link(@notification)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /notifications/1
    # DELETE /notifications/1.json
    def destroy
      @notification = Notification.find(params[:id])

      respond_to do |format|
        if @notification.destroy
          format.html { redirect_to notifications_url,
                      notice: (crud_notice('destroyed', @notification) + "#{undo_link(@notification)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to notifications_url, alert: "#{@notification.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Notification.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end
