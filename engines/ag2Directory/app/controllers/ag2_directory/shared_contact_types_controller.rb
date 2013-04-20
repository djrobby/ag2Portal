require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class SharedContactTypesController < ApplicationController
    # GET /shared_contact_types
    # GET /shared_contact_types.json
    def index
      @shared_contact_types = SharedContactType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @shared_contact_types }
      end
    end
  
    # GET /shared_contact_types/1
    # GET /shared_contact_types/1.json
    def show
      @breadcrumb = 'read'
      @shared_contact_type = SharedContactType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @shared_contact_type }
      end
    end
  
    # GET /shared_contact_types/new
    # GET /shared_contact_types/new.json
    def new
      @breadcrumb = 'create'
      @shared_contact_type = SharedContactType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @shared_contact_type }
      end
    end
  
    # GET /shared_contact_types/1/edit
    def edit
      @breadcrumb = 'update'
      @shared_contact_type = SharedContactType.find(params[:id])
    end
  
    # POST /shared_contact_types
    # POST /shared_contact_types.json
    def create
      @breadcrumb = 'create'
      @shared_contact_type = SharedContactType.new(params[:shared_contact_type])
  
      respond_to do |format|
        if @shared_contact_type.save
          format.html { redirect_to @shared_contact_type, notice: 'Shared contact type was successfully created.' }
          format.json { render json: @shared_contact_type, status: :created, location: @shared_contact_type }
        else
          format.html { render action: "new" }
          format.json { render json: @shared_contact_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /shared_contact_types/1
    # PUT /shared_contact_types/1.json
    def update
      @breadcrumb = 'update'
      @shared_contact_type = SharedContactType.find(params[:id])
  
      respond_to do |format|
        if @shared_contact_type.update_attributes(params[:shared_contact_type])
          format.html { redirect_to @shared_contact_type, notice: 'Shared contact type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @shared_contact_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /shared_contact_types/1
    # DELETE /shared_contact_types/1.json
    def destroy
      @shared_contact_type = SharedContactType.find(params[:id])
      @shared_contact_type.destroy
  
      respond_to do |format|
        format.html { redirect_to shared_contact_types_url }
        format.json { head :no_content }
      end
    end
  end
end
