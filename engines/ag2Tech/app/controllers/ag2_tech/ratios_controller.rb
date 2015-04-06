require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class RatiosController < ApplicationController
    # GET /ratios
    # GET /ratios.json
    def index
      @ratios = Ratio.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ratios }
      end
    end
  
    # GET /ratios/1
    # GET /ratios/1.json
    def show
      @ratio = Ratio.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ratio }
      end
    end
  
    # GET /ratios/new
    # GET /ratios/new.json
    def new
      @ratio = Ratio.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ratio }
      end
    end
  
    # GET /ratios/1/edit
    def edit
      @ratio = Ratio.find(params[:id])
    end
  
    # POST /ratios
    # POST /ratios.json
    def create
      @ratio = Ratio.new(params[:ratio])
  
      respond_to do |format|
        if @ratio.save
          format.html { redirect_to @ratio, notice: 'Ratio was successfully created.' }
          format.json { render json: @ratio, status: :created, location: @ratio }
        else
          format.html { render action: "new" }
          format.json { render json: @ratio.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /ratios/1
    # PUT /ratios/1.json
    def update
      @ratio = Ratio.find(params[:id])
  
      respond_to do |format|
        if @ratio.update_attributes(params[:ratio])
          format.html { redirect_to @ratio, notice: 'Ratio was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ratio.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /ratios/1
    # DELETE /ratios/1.json
    def destroy
      @ratio = Ratio.find(params[:id])
      @ratio.destroy
  
      respond_to do |format|
        format.html { redirect_to ratios_url }
        format.json { head :no_content }
      end
    end
  end
end
