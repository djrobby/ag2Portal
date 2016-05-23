require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class InfrastructuresController < ApplicationController
    # GET /infrastructures
    # GET /infrastructures.json
    def index
      @infrastructures = Infrastructure.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @infrastructures }
      end
    end
  
    # GET /infrastructures/1
    # GET /infrastructures/1.json
    def show
      @infrastructure = Infrastructure.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @infrastructure }
      end
    end
  
    # GET /infrastructures/new
    # GET /infrastructures/new.json
    def new
      @infrastructure = Infrastructure.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @infrastructure }
      end
    end
  
    # GET /infrastructures/1/edit
    def edit
      @infrastructure = Infrastructure.find(params[:id])
    end
  
    # POST /infrastructures
    # POST /infrastructures.json
    def create
      @infrastructure = Infrastructure.new(params[:infrastructure])
  
      respond_to do |format|
        if @infrastructure.save
          format.html { redirect_to @infrastructure, notice: 'Infrastructure was successfully created.' }
          format.json { render json: @infrastructure, status: :created, location: @infrastructure }
        else
          format.html { render action: "new" }
          format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /infrastructures/1
    # PUT /infrastructures/1.json
    def update
      @infrastructure = Infrastructure.find(params[:id])
  
      respond_to do |format|
        if @infrastructure.update_attributes(params[:infrastructure])
          format.html { redirect_to @infrastructure, notice: 'Infrastructure was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @infrastructure.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /infrastructures/1
    # DELETE /infrastructures/1.json
    def destroy
      @infrastructure = Infrastructure.find(params[:id])
      @infrastructure.destroy
  
      respond_to do |format|
        format.html { redirect_to infrastructures_url }
        format.json { head :no_content }
      end
    end
  end
end
