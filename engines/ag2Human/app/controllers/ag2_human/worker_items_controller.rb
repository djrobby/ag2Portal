require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerItemsController < ApplicationController
    # GET /worker_items
    # GET /worker_items.json
    def index
      @worker_items = WorkerItem.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_items }
      end
    end
  
    # GET /worker_items/1
    # GET /worker_items/1.json
    def show
      @worker_item = WorkerItem.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_item }
      end
    end
  
    # GET /worker_items/new
    # GET /worker_items/new.json
    def new
      @worker_item = WorkerItem.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_item }
      end
    end
  
    # GET /worker_items/1/edit
    def edit
      @worker_item = WorkerItem.find(params[:id])
    end
  
    # POST /worker_items
    # POST /worker_items.json
    def create
      @worker_item = WorkerItem.new(params[:worker_item])
  
      respond_to do |format|
        if @worker_item.save
          format.html { redirect_to @worker_item, notice: 'Worker item was successfully created.' }
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
      @worker_item = WorkerItem.find(params[:id])
  
      respond_to do |format|
        if @worker_item.update_attributes(params[:worker_item])
          format.html { redirect_to @worker_item, notice: 'Worker item was successfully updated.' }
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
      @worker_item.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_items_url }
        format.json { head :no_content }
      end
    end
  end
end
