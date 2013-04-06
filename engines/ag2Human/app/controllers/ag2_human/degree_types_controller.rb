require_dependency "ag2_human/application_controller"

module Ag2Human
  class DegreeTypesController < ApplicationController
    # GET /degree_types
    # GET /degree_types.json
    def index
      @degree_types = DegreeType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @degree_types }
      end
    end
  
    # GET /degree_types/1
    # GET /degree_types/1.json
    def show
      @breadcrumb = 'read'
      @degree_type = DegreeType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @degree_type }
      end
    end
  
    # GET /degree_types/new
    # GET /degree_types/new.json
    def new
      @breadcrumb = 'create'
      @degree_type = DegreeType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @degree_type }
      end
    end
  
    # GET /degree_types/1/edit
    def edit
      @breadcrumb = 'update'
      @degree_type = DegreeType.find(params[:id])
    end
  
    # POST /degree_types
    # POST /degree_types.json
    def create
      @breadcrumb = 'create'
      @degree_type = DegreeType.new(params[:degree_type])
  
      respond_to do |format|
        if @degree_type.save
          format.html { redirect_to @degree_type, notice: 'Degree type was successfully created.' }
          format.json { render json: @degree_type, status: :created, location: @degree_type }
        else
          format.html { render action: "new" }
          format.json { render json: @degree_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /degree_types/1
    # PUT /degree_types/1.json
    def update
      @breadcrumb = 'update'
      @degree_type = DegreeType.find(params[:id])
  
      respond_to do |format|
        if @degree_type.update_attributes(params[:degree_type])
          format.html { redirect_to @degree_type, notice: 'Degree type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @degree_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /degree_types/1
    # DELETE /degree_types/1.json
    def destroy
      @degree_type = DegreeType.find(params[:id])
      @degree_type.destroy
  
      respond_to do |format|
        format.html { redirect_to degree_types_url }
        format.json { head :no_content }
      end
    end
  end
end
