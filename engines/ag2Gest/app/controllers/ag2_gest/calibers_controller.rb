require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CalibersController < ApplicationController
    # GET /calibers
    # GET /calibers.json
    def index
      @calibers = Caliber.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @calibers }
      end
    end
  
    # GET /calibers/1
    # GET /calibers/1.json
    def show
      @caliber = Caliber.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @caliber }
      end
    end
  
    # GET /calibers/new
    # GET /calibers/new.json
    def new
      @caliber = Caliber.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @caliber }
      end
    end
  
    # GET /calibers/1/edit
    def edit
      @caliber = Caliber.find(params[:id])
    end
  
    # POST /calibers
    # POST /calibers.json
    def create
      @caliber = Caliber.new(params[:caliber])
  
      respond_to do |format|
        if @caliber.save
          format.html { redirect_to @caliber, notice: 'Caliber was successfully created.' }
          format.json { render json: @caliber, status: :created, location: @caliber }
        else
          format.html { render action: "new" }
          format.json { render json: @caliber.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /calibers/1
    # PUT /calibers/1.json
    def update
      @caliber = Caliber.find(params[:id])
  
      respond_to do |format|
        if @caliber.update_attributes(params[:caliber])
          format.html { redirect_to @caliber, notice: 'Caliber was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @caliber.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /calibers/1
    # DELETE /calibers/1.json
    def destroy
      @caliber = Caliber.find(params[:id])
      @caliber.destroy
  
      respond_to do |format|
        format.html { redirect_to calibers_url }
        format.json { head :no_content }
      end
    end
  end
end
