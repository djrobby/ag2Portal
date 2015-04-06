require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class RatioGroupsController < ApplicationController
    # GET /ratio_groups
    # GET /ratio_groups.json
    def index
      @ratio_groups = RatioGroup.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ratio_groups }
      end
    end
  
    # GET /ratio_groups/1
    # GET /ratio_groups/1.json
    def show
      @ratio_group = RatioGroup.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ratio_group }
      end
    end
  
    # GET /ratio_groups/new
    # GET /ratio_groups/new.json
    def new
      @ratio_group = RatioGroup.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ratio_group }
      end
    end
  
    # GET /ratio_groups/1/edit
    def edit
      @ratio_group = RatioGroup.find(params[:id])
    end
  
    # POST /ratio_groups
    # POST /ratio_groups.json
    def create
      @ratio_group = RatioGroup.new(params[:ratio_group])
  
      respond_to do |format|
        if @ratio_group.save
          format.html { redirect_to @ratio_group, notice: 'Ratio group was successfully created.' }
          format.json { render json: @ratio_group, status: :created, location: @ratio_group }
        else
          format.html { render action: "new" }
          format.json { render json: @ratio_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /ratio_groups/1
    # PUT /ratio_groups/1.json
    def update
      @ratio_group = RatioGroup.find(params[:id])
  
      respond_to do |format|
        if @ratio_group.update_attributes(params[:ratio_group])
          format.html { redirect_to @ratio_group, notice: 'Ratio group was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ratio_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /ratio_groups/1
    # DELETE /ratio_groups/1.json
    def destroy
      @ratio_group = RatioGroup.find(params[:id])
      @ratio_group.destroy
  
      respond_to do |format|
        format.html { redirect_to ratio_groups_url }
        format.json { head :no_content }
      end
    end
  end
end
