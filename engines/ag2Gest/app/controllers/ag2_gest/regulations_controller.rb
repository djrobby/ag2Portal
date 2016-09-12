require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class RegulationsController < ApplicationController
    # GET /regulations
    # GET /regulations.json
    def index
      @regulations = Regulation.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @regulations }
      end
    end
  
    # GET /regulations/1
    # GET /regulations/1.json
    def show
      @regulation = Regulation.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @regulation }
      end
    end
  
    # GET /regulations/new
    # GET /regulations/new.json
    def new
      @regulation = Regulation.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @regulation }
      end
    end
  
    # GET /regulations/1/edit
    def edit
      @regulation = Regulation.find(params[:id])
    end
  
    # POST /regulations
    # POST /regulations.json
    def create
      @regulation = Regulation.new(params[:regulation])
  
      respond_to do |format|
        if @regulation.save
          format.html { redirect_to @regulation, notice: 'Regulation was successfully created.' }
          format.json { render json: @regulation, status: :created, location: @regulation }
        else
          format.html { render action: "new" }
          format.json { render json: @regulation.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /regulations/1
    # PUT /regulations/1.json
    def update
      @regulation = Regulation.find(params[:id])
  
      respond_to do |format|
        if @regulation.update_attributes(params[:regulation])
          format.html { redirect_to @regulation, notice: 'Regulation was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @regulation.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /regulations/1
    # DELETE /regulations/1.json
    def destroy
      @regulation = Regulation.find(params[:id])
      @regulation.destroy
  
      respond_to do |format|
        format.html { redirect_to regulations_url }
        format.json { head :no_content }
      end
    end
  end
end
