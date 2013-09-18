require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class StreetTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /street_types
    # GET /street_types.json
    def index
      @street_types = StreetType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @street_types }
      end
    end

    # GET /street_types/1
    # GET /street_types/1.json
    def show
      @breadcrumb = 'read'
      @street_type = StreetType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @street_type }
      end
    end

    # GET /street_types/new
    # GET /street_types/new.json
    def new
      @breadcrumb = 'create'
      @street_type = StreetType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @street_type }
      end
    end

    # GET /street_types/1/edit
    def edit
      @breadcrumb = 'update'
      @street_type = StreetType.find(params[:id])
    end

    # POST /street_types
    # POST /street_types.json
    def create
      @breadcrumb = 'create'
      @street_type = StreetType.new(params[:street_type])
      @street_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @street_type.save
          format.html { redirect_to @street_type, notice: crud_notice('created', @street_type) }
          format.json { render json: @street_type, status: :created, location: @street_type }
        else
          format.html { render action: "new" }
          format.json { render json: @street_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /street_types/1
    # PUT /street_types/1.json
    def update
      @breadcrumb = 'update'
      @street_type = StreetType.find(params[:id])
      @street_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @street_type.update_attributes(params[:street_type])
          format.html { redirect_to @street_type,
                        notice: (crud_notice('updated', @street_type) + "#{undo_link(@street_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @street_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /street_types/1
    # DELETE /street_types/1.json
    def destroy
      @street_type = StreetType.find(params[:id])
      @street_type.destroy

      respond_to do |format|
        format.html { redirect_to street_types_url,
                      notice: (crud_notice('destroyed', @street_type) + "#{undo_link(@street_type)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      StreetType.column_names.include?(params[:sort]) ? params[:sort] : "street_type_code"
    end
  end
end
