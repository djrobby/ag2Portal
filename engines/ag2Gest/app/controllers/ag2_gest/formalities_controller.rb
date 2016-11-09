require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class FormalitiesController < ApplicationController
    # GET /formalities
    # GET /formalities.json
    def index
      @formalities = Formality.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @formalities }
      end
    end
  
    # GET /formalities/1
    # GET /formalities/1.json
    def show
      @formality = Formality.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @formality }
      end
    end
  
    # GET /formalities/new
    # GET /formalities/new.json
    def new
      @formality = Formality.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @formality }
      end
    end
  
    # GET /formalities/1/edit
    def edit
      @formality = Formality.find(params[:id])
    end
  
    # POST /formalities
    # POST /formalities.json
    def create
      @formality = Formality.new(params[:formality])
  
      respond_to do |format|
        if @formality.save
          format.html { redirect_to @formality, notice: 'Formality was successfully created.' }
          format.json { render json: @formality, status: :created, location: @formality }
        else
          format.html { render action: "new" }
          format.json { render json: @formality.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /formalities/1
    # PUT /formalities/1.json
    def update
      @formality = Formality.find(params[:id])
  
      respond_to do |format|
        if @formality.update_attributes(params[:formality])
          format.html { redirect_to @formality, notice: 'Formality was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @formality.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /formalities/1
    # DELETE /formalities/1.json
    def destroy
      @formality = Formality.find(params[:id])
      @formality.destroy
  
      respond_to do |format|
        format.html { redirect_to formalities_url }
        format.json { head :no_content }
      end
    end
  end
end
