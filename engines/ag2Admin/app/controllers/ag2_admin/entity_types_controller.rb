require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class EntityTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /entity_types
    # GET /entity_types.json
    def index
      @entity_types = EntityType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @entity_types }
      end
    end
  
    # GET /entity_types/1
    # GET /entity_types/1.json
    def show
      @breadcrumb = 'read'
      @entity_type = EntityType.find(params[:id])
      @entities = @entity_type.entities.paginate(:page => params[:page], :per_page => per_page).order('fiscal_id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @entity_type }
      end
    end
  
    # GET /entity_types/new
    # GET /entity_types/new.json
    def new
      @breadcrumb = 'create'
      @entity_type = EntityType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @entity_type }
      end
    end
  
    # GET /entity_types/1/edit
    def edit
      @breadcrumb = 'update'
      @entity_type = EntityType.find(params[:id])
    end
  
    # POST /entity_types
    # POST /entity_types.json
    def create
      @breadcrumb = 'create'
      @entity_type = EntityType.new(params[:entity_type])
      @entity_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @entity_type.save
          format.html { redirect_to @entity_type, notice: crud_notice('created', @entity_type) }
          format.json { render json: @entity_type, status: :created, location: @entity_type }
        else
          format.html { render action: "new" }
          format.json { render json: @entity_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /entity_types/1
    # PUT /entity_types/1.json
    def update
      @breadcrumb = 'update'
      @entity_type = EntityType.find(params[:id])
      @entity_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @entity_type.update_attributes(params[:entity_type])
          format.html { redirect_to @entity_type,
                        notice: (crud_notice('updated', @entity_type) + "#{undo_link(@entity_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @entity_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /entity_types/1
    # DELETE /entity_types/1.json
    def destroy
      @entity_type = EntityType.find(params[:id])
      @entity_type.destroy
  
      respond_to do |format|
        format.html { redirect_to entity_types_url,
                      notice: (crud_notice('destroyed', @entity_type) + "#{undo_link(@entity_type)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      EntityType.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
