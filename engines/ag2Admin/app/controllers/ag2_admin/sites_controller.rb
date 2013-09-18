require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class SitesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /sites
    # GET /sites.json
    def index
      @sites = Site.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sites }
      end
    end

    # GET /sites/1
    # GET /sites/1.json
    def show
      @breadcrumb = 'read'
      @site = Site.find(params[:id])
      @apps = @site.apps

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @site }
      end
    end

    # GET /sites/new
    # GET /sites/new.json
    def new
      @breadcrumb = 'create'
      @site = Site.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @site }
      end
    end

    # GET /sites/1/edit
    def edit
      @breadcrumb = 'update'
      @site = Site.find(params[:id])
    end

    # POST /sites
    # POST /sites.json
    def create
      @breadcrumb = 'create'
      @site = Site.new(params[:site])
      @site.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @site.save
          format.html { redirect_to @site, notice: crud_notice('created', @site) }
          format.json { render json: @site, status: :created, location: @site }
        else
          format.html { render action: "new" }
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /sites/1
    # PUT /sites/1.json
    def update
      @breadcrumb = 'update'
      @site = Site.find(params[:id])
      @site.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @site.update_attributes(params[:site])
          format.html { redirect_to @site,
                        notice: (crud_notice('updated', @site) + "#{undo_link(@site)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sites/1
    # DELETE /sites/1.json
    def destroy
      @site = Site.find(params[:id])
      @site.destroy

      respond_to do |format|
        format.html { redirect_to sites_url,
                      notice: (crud_notice('destroyed', @site) + "#{undo_link(@site)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      Site.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end
