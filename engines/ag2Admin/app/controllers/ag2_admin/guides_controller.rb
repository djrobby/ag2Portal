require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class GuidesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => :gu_update_site_from_app
    # Helper methods for sorting
    helper_method :sort_column

    # Update site text field at view from app select
    def gu_update_site_from_app
      @app = App.find(params[:app]) rescue nil
      @site = !@app.nil? ? @app.site : nil

      respond_to do |format|
        format.html # gu_update_site_from_app.html.erb does not exist! JSON only
        format.json { render json: @site }
      end
    end

    #
    # Default Methods
    #
    # GET /guides
    # GET /guides.json
    def index
      @guides = Guide.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @guides }
      end
    end
  
    # GET /guides/1
    # GET /guides/1.json
    def show
      @breadcrumb = 'read'
      @guide = Guide.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @guide }
      end
    end
  
    # GET /guides/new
    # GET /guides/new.json
    def new
      @breadcrumb = 'create'
      @guide = Guide.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @guide }
      end
    end
  
    # GET /guides/1/edit
    def edit
      @breadcrumb = 'update'
      @guide = Guide.find(params[:id])
    end
  
    # POST /guides
    # POST /guides.json
    def create
      @breadcrumb = 'create'
      @guide = Guide.new(params[:guide])
      @guide.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @guide.save
          format.html { redirect_to @guide, notice: crud_notice('created', @guide) }
          format.json { render json: @guide, status: :created, location: @guide }
        else
          format.html { render action: "new" }
          format.json { render json: @guide.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /guides/1
    # PUT /guides/1.json
    def update
      @breadcrumb = 'update'
      @guide = Guide.find(params[:id])
      @guide.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @guide.update_attributes(params[:guide])
          format.html { redirect_to @guide,
                        notice: (crud_notice('updated', @guide) + "#{undo_link(@guide)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @guide.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /guides/1
    # DELETE /guides/1.json
    def destroy
      @guide = Guide.find(params[:id])

      respond_to do |format|
        if @guide.destroy
          format.html { redirect_to guides_url,
                      notice: (crud_notice('destroyed', @guide) + "#{undo_link(@guide)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to guides_url, alert: "#{@guide.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @guide.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Guide.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end
