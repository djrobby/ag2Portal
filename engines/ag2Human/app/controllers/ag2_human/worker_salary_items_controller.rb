require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerSalaryItemsController < ApplicationController
    # GET /worker_salary_items
    # GET /worker_salary_items.json
    def index
      @worker_salary_items = WorkerSalaryItem.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_salary_items }
      end
    end
  
    # GET /worker_salary_items/1
    # GET /worker_salary_items/1.json
    def show
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_salary_item }
      end
    end
  
    # GET /worker_salary_items/new
    # GET /worker_salary_items/new.json
    def new
      @worker_salary_item = WorkerSalaryItem.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_salary_item }
      end
    end
  
    # GET /worker_salary_items/1/edit
    def edit
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
    end
  
    # POST /worker_salary_items
    # POST /worker_salary_items.json
    def create
      @worker_salary_item = WorkerSalaryItem.new(params[:worker_salary_item])
  
      respond_to do |format|
        if @worker_salary_item.save
          format.html { redirect_to @worker_salary_item, notice: 'Worker salary item was successfully created.' }
          format.json { render json: @worker_salary_item, status: :created, location: @worker_salary_item }
        else
          format.html { render action: "new" }
          format.json { render json: @worker_salary_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /worker_salary_items/1
    # PUT /worker_salary_items/1.json
    def update
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
  
      respond_to do |format|
        if @worker_salary_item.update_attributes(params[:worker_salary_item])
          format.html { redirect_to @worker_salary_item, notice: 'Worker salary item was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @worker_salary_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /worker_salary_items/1
    # DELETE /worker_salary_items/1.json
    def destroy
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
      @worker_salary_item.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_salary_items_url }
        format.json { head :no_content }
      end
    end
  end
end
