require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class SubguidesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /subguides
    # GET /subguides.json
    def index
      @subguides = Subguide.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subguides }
      end
    end
  
    # GET /subguides/1
    # GET /subguides/1.json
    def show
      @breadcrumb = 'read'
      @subguide = Subguide.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @subguide }
      end
    end
  
    # GET /subguides/new
    # GET /subguides/new.json
    def new
      @breadcrumb = 'create'
      @subguide = Subguide.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subguide }
      end
    end
  
    # GET /subguides/1/edit
    def edit
      @breadcrumb = 'update'
      @subguide = Subguide.find(params[:id])
    end
  
    # POST /subguides
    # POST /subguides.json
    def create
      @breadcrumb = 'create'
      @subguide = Subguide.new(params[:subguide])
      @subguide.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @subguide.save
          format.html { redirect_to @subguide, notice: crud_notice('created', @subguide) }
          format.json { render json: @subguide, status: :created, location: @subguide }
        else
          format.html { render action: "new" }
          format.json { render json: @subguide.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /subguides/1
    # PUT /subguides/1.json
    def update
      @breadcrumb = 'update'
      @subguide = Subguide.find(params[:id])
      @subguide.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @subguide.update_attributes(params[:subguide])
          format.html { redirect_to @subguide,
                        notice: (crud_notice('updated', @subguide) + "#{undo_link(@subguide)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subguide.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /subguides/1
    # DELETE /subguides/1.json
    def destroy
      @subguide = Subguide.find(params[:id])

      respond_to do |format|
        if @subguide.destroy
          format.html { redirect_to subguides_url,
                      notice: (crud_notice('destroyed', @subguide) + "#{undo_link(@subguide)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to subguides_url, alert: "#{@subguide.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @subguide.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Subguide.column_names.include?(params[:sort]) ? params[:sort] : "sort_order"
    end
  end
end
