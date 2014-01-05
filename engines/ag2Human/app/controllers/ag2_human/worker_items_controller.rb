require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerItemsController < ApplicationController
    # GET /worker_items
    # GET /worker_items.json
    def index
      @worker_items = WorkerItem.paginate(:page => params[:page], :per_page => per_page)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_items }
      end
    end
  
    # GET /worker_items/1
    # GET /worker_items/1.json
    def show
      @breadcrumb = 'read'
      @worker_item = WorkerItem.find(params[:id])
      @worker_salaries = @worker_item.worker_salaries.paginate(:page => params[:page], :per_page => per_page).order('year desc')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_item }
      end
    end
  
    # GET /worker_items/new
    # GET /worker_items/new.json
    def new
      if !params[:worker].nil?
        @worker = Worker.find(params[:worker])
      end
      @breadcrumb = 'create'
      @worker_item = WorkerItem.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_item }
      end
    end
  
    # GET /worker_items/1/edit
    def edit
      @breadcrumb = 'update'
      @worker_item = WorkerItem.find(params[:id])
    end
  
    # POST /worker_items
    # POST /worker_items.json
    def create
      @breadcrumb = 'create'
      @worker_item = WorkerItem.new(params[:worker_item])
      @worker_item.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_item.save
          format.html { redirect_to @worker_item, notice: crud_notice('created', @worker_item) }
          format.json { render json: @worker_item, status: :created, location: @worker_item }
        else
          format.html { render action: "new" }
          format.json { render json: @worker_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /worker_items/1
    # PUT /worker_items/1.json
    def update
      @breadcrumb = 'update'
      @worker_item = WorkerItem.find(params[:id])
      @worker_item.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_item.update_attributes(params[:worker_item])
          format.html { redirect_to @worker_item,
                        notice: (crud_notice('updated', @worker_item) + "#{undo_link(@worker_item)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @worker_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /worker_items/1
    # DELETE /worker_items/1.json
    def destroy
      @worker_item = WorkerItem.find(params[:id])
      worker = @worker_item.worker

      respond_to do |format|
        if @worker_item.destroy
          format.html { redirect_to worker,
                      notice: (crud_notice('destroyed', @worker_item) + "#{undo_link(@worker_item)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to worker, alert: "#{@worker_item.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @worker_item.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
