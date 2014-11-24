require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ToolsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /tools
    # GET /tools.json
    def index
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @tools = Tool.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @tools = Tool.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tools }
        format.js
      end
    end
  
    # GET /tools/1
    # GET /tools/1.json
    def show
      @tool = Tool.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tool }
      end
    end
  
    # GET /tools/new
    # GET /tools/new.json
    def new
      @tool = Tool.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tool }
      end
    end
  
    # GET /tools/1/edit
    def edit
      @tool = Tool.find(params[:id])
    end
  
    # POST /tools
    # POST /tools.json
    def create
      @tool = Tool.new(params[:tool])
  
      respond_to do |format|
        if @tool.save
          format.html { redirect_to @tool, notice: 'Tool was successfully created.' }
          format.json { render json: @tool, status: :created, location: @tool }
        else
          format.html { render action: "new" }
          format.json { render json: @tool.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /tools/1
    # PUT /tools/1.json
    def update
      @tool = Tool.find(params[:id])
  
      respond_to do |format|
        if @tool.update_attributes(params[:tool])
          format.html { redirect_to @tool, notice: 'Tool was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @tool.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tools/1
    # DELETE /tools/1.json
    def destroy
      @tool = Tool.find(params[:id])
      @tool.destroy
  
      respond_to do |format|
        format.html { redirect_to tools_url }
        format.json { head :no_content }
      end
    end
  end
end
