require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class RegionsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /regions
    # GET /regions.json
    def index
      @regions = Region.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @regions }
      end
    end

    # GET /regions/1
    # GET /regions/1.json
    def show
      @breadcrumb = 'read'
      @region = Region.find(params[:id])
      @provinces = @region.provinces.order("name")

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @region }
      end
    end

    # GET /regions/new
    # GET /regions/new.json
    def new
      @breadcrumb = 'create'
      @region = Region.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @region }
      end
    end

    # GET /regions/1/edit
    def edit
      @breadcrumb = 'update'
      @region = Region.find(params[:id])
    end

    # POST /regions
    # POST /regions.json
    def create
      @breadcrumb = 'create'
      @region = Region.new(params[:region])
      @region.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @region.save
          format.html { redirect_to @region, notice: crud_notice('created', @region) }
          format.json { render json: @region, status: :created, location: @region }
        else
          format.html { render action: "new" }
          format.json { render json: @region.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /regions/1
    # PUT /regions/1.json
    def update
      @breadcrumb = 'update'
      @region = Region.find(params[:id])
      @region.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @region.update_attributes(params[:region])
          format.html { redirect_to @region,
                        notice: (crud_notice('updated', @region) + "#{undo_link(@region)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @region.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /regions/1
    # DELETE /regions/1.json
    def destroy
      @region = Region.find(params[:id])

      respond_to do |format|
        if @region.destroy
          format.html { redirect_to regions_url,
                      notice: (crud_notice('destroyed', @region) + "#{undo_link(@region)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to regions_url, alert: "#{@region.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @region.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Region.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
