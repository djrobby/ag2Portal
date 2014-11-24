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
      manage_filter_state
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
      @breadcrumb = 'read'
      @tool = Tool.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tool }
      end
    end
  
    # GET /tools/new
    # GET /tools/new.json
    def new
      @breadcrumb = 'create'
      @tool = Tool.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tool }
      end
    end
  
    # GET /tools/1/edit
    def edit
      @breadcrumb = 'update'
      @tool = Tool.find(params[:id])
    end
  
    # POST /tools
    # POST /tools.json
    def create
      @breadcrumb = 'create'
      @tool = Tool.new(params[:tool])
      @tool.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @tool.save
          format.html { redirect_to @tool, notice: crud_notice('created', @tool) }
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
      @breadcrumb = 'update'
      @tool = Tool.find(params[:id])
      @tool.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @tool.update_attributes(params[:tool])
          format.html { redirect_to @tool,
                        notice: (crud_notice('updated', @tool) + "#{undo_link(@tool)}").html_safe }
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

      respond_to do |format|
        if @tool.destroy
          format.html { redirect_to tools_url,
                      notice: (crud_notice('destroyed', @tool) + "#{undo_link(@tool)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to tools_url, alert: "#{@tool.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @tool.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Tool.column_names.include?(params[:sort]) ? params[:sort] : "serial_no"
    end

    # Keeps filter state
    def manage_filter_state
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end
  end
end
