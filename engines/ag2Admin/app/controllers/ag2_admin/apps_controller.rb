require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class AppsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /apps
    # GET /apps.json
    def index
      @apps = App.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @apps }
      end
    end

    # GET /apps/1
    # GET /apps/1.json
    def show
      @breadcrumb = 'read'
      @app = App.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @app }
      end
    end

    # GET /apps/new
    # GET /apps/new.json
    def new
      @breadcrumb = 'create'
      @app = App.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @app }
      end
    end

    # GET /apps/1/edit
    def edit
      @breadcrumb = 'update'
      @app = App.find(params[:id])
    end

    # POST /apps
    # POST /apps.json
    def create
      @breadcrumb = 'create'
      @app = App.new(params[:app])
      @app.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @app.save
          format.html { redirect_to @app, notice: crud_notice('created', @app) }
          format.json { render json: @app, status: :created, location: @app }
        else
          format.html { render action: "new" }
          format.json { render json: @app.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /apps/1
    # PUT /apps/1.json
    def update
      @breadcrumb = 'update'
      @app = App.find(params[:id])
      @app.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @app.update_attributes(params[:app])
          format.html { redirect_to @app,
                        notice: (crud_notice('updated', @app) + "#{undo_link(@app)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @app.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /apps/1
    # DELETE /apps/1.json
    def destroy
      @app = App.find(params[:id])

      respond_to do |format|
        if @app.destroy
          format.html { redirect_to apps_url,
                      notice: (crud_notice('destroyed', @app) + "#{undo_link(@app)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to apps_url, alert: "#{@app.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @app.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      App.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end
