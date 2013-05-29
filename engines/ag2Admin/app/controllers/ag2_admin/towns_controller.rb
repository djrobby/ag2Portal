require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class TownsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # GET /towns
    # GET /towns.json
    def index
      @towns = Town.paginate(:page => params[:page], :per_page => per_page).order('name')

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @towns }
      end
    end

    # GET /towns/1
    # GET /towns/1.json
    def show
      @breadcrumb = 'read'
      @town = Town.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @town }
      end
    end

    # GET /towns/new
    # GET /towns/new.json
    def new
      @breadcrumb = 'create'
      @town = Town.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @town }
      end
    end

    # GET /towns/1/edit
    def edit
      @breadcrumb = 'update'
      @town = Town.find(params[:id])
    end

    # POST /towns
    # POST /towns.json
    def create
      @breadcrumb = 'create'
      @town = Town.new(params[:town])
      @town.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @town.save
          format.html { redirect_to @town, notice: crud_notice('created', @town) }
          format.json { render json: @town, status: :created, location: @town }
        else
          format.html { render action: "new" }
          format.json { render json: @town.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /towns/1
    # PUT /towns/1.json
    def update
      @breadcrumb = 'update'
      @town = Town.find(params[:id])
      @town.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @town.update_attributes(params[:town])
          format.html { redirect_to @town,
                        notice: (crud_notice('updated', @town) + "#{undo_link(@town)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @town.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /towns/1
    # DELETE /towns/1.json
    def destroy
      @town = Town.find(params[:id])
      @town.destroy

      respond_to do |format|
        format.html { redirect_to towns_url,
                      notice: (crud_notice('destroyed', @town) + "#{undo_link(@town)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
