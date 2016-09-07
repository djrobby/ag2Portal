require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ReadingRoutesController < ApplicationController
    # GET /reading_routes
    # GET /reading_routes.json
    def index
      @reading_routes = ReadingRoute.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @reading_routes }
      end
    end
  
    # GET /reading_routes/1
    # GET /reading_routes/1.json
    def show
      @reading_route = ReadingRoute.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reading_route }
      end
    end
  
    # GET /reading_routes/new
    # GET /reading_routes/new.json
    def new
      @reading_route = ReadingRoute.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reading_route }
      end
    end
  
    # GET /reading_routes/1/edit
    def edit
      @reading_route = ReadingRoute.find(params[:id])
    end
  
    # POST /reading_routes
    # POST /reading_routes.json
    def create
      @reading_route = ReadingRoute.new(params[:reading_route])
  
      respond_to do |format|
        if @reading_route.save
          format.html { redirect_to @reading_route, notice: 'Reading route was successfully created.' }
          format.json { render json: @reading_route, status: :created, location: @reading_route }
        else
          format.html { render action: "new" }
          format.json { render json: @reading_route.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /reading_routes/1
    # PUT /reading_routes/1.json
    def update
      @reading_route = ReadingRoute.find(params[:id])
  
      respond_to do |format|
        if @reading_route.update_attributes(params[:reading_route])
          format.html { redirect_to @reading_route, notice: 'Reading route was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reading_route.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /reading_routes/1
    # DELETE /reading_routes/1.json
    def destroy
      @reading_route = ReadingRoute.find(params[:id])
      @reading_route.destroy
  
      respond_to do |format|
        format.html { redirect_to reading_routes_url }
        format.json { head :no_content }
      end
    end
  end
end
