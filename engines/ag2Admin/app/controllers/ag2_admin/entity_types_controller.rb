require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class EntityTypesController < ApplicationController
    # GET /entity_types
    # GET /entity_types.json
    def index
      @entity_types = EntityType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @entity_types }
      end
    end
  
    # GET /entity_types/1
    # GET /entity_types/1.json
    def show
      @entity_type = EntityType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @entity_type }
      end
    end
  
    # GET /entity_types/new
    # GET /entity_types/new.json
    def new
      @entity_type = EntityType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @entity_type }
      end
    end
  
    # GET /entity_types/1/edit
    def edit
      @entity_type = EntityType.find(params[:id])
    end
  
    # POST /entity_types
    # POST /entity_types.json
    def create
      @entity_type = EntityType.new(params[:entity_type])
  
      respond_to do |format|
        if @entity_type.save
          format.html { redirect_to @entity_type, notice: 'Entity type was successfully created.' }
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
      @entity_type = EntityType.find(params[:id])
  
      respond_to do |format|
        if @entity_type.update_attributes(params[:entity_type])
          format.html { redirect_to @entity_type, notice: 'Entity type was successfully updated.' }
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
        format.html { redirect_to entity_types_url }
        format.json { head :no_content }
      end
    end
  end
end
