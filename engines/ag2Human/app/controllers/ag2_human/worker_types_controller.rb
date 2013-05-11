require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /worker_types
    # GET /worker_types.json
    def index
      @worker_types = WorkerType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_types }
      end
    end
  
    # GET /worker_types/1
    # GET /worker_types/1.json
    def show
      @breadcrumb = 'read'
      @worker_type = WorkerType.find(params[:id])
      @workers = @worker_type.workers
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_type }
      end
    end
  
    # GET /worker_types/new
    # GET /worker_types/new.json
    def new
      @breadcrumb = 'create'
      @worker_type = WorkerType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_type }
      end
    end
  
    # GET /worker_types/1/edit
    def edit
      @breadcrumb = 'update'
      @worker_type = WorkerType.find(params[:id])
    end
  
    # POST /worker_types
    # POST /worker_types.json
    def create
      @breadcrumb = 'create'
      @worker_type = WorkerType.new(params[:worker_type])
      @worker_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_type.save
          format.html { redirect_to @worker_type, notice: I18n.t('activerecord.successful.messages.created', :model => @worker_type.class.model_name.human) }
          format.json { render json: @worker_type, status: :created, location: @worker_type }
        else
          format.html { render action: "new" }
          format.json { render json: @worker_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /worker_types/1
    # PUT /worker_types/1.json
    def update
      @breadcrumb = 'update'
      @worker_type = WorkerType.find(params[:id])
      @worker_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_type.update_attributes(params[:worker_type])
          format.html { redirect_to @worker_type, notice: I18n.t('activerecord.successful.messages.updated', :model => @worker_type.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @worker_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /worker_types/1
    # DELETE /worker_types/1.json
    def destroy
      @worker_type = WorkerType.find(params[:id])
      @worker_type.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_types_url }
        format.json { head :no_content }
      end
    end
  end
end
