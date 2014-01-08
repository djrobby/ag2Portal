require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerSalaryItemsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /worker_salary_items
    # GET /worker_salary_items.json
    def index
      @worker_salary_items = WorkerSalaryItem.paginate(:page => params[:page], :per_page => per_page).order('worker_salary_id desc')
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_salary_items }
      end
    end
  
    # GET /worker_salary_items/1
    # GET /worker_salary_items/1.json
    def show
      if !params[:salary].nil?
        @worker_salary = WorkerSalary.find(params[:salary])
      end
      @breadcrumb = 'read'
      @worker_salary_item = WorkerSalaryItem.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_salary_item }
      end
    end
  
    # GET /worker_salary_items/new
    # GET /worker_salary_items/new.json
    def new
      if !params[:salary].nil?
        @worker_salary = WorkerSalary.find(params[:salary])
      end
      @breadcrumb = 'create'
      @worker_salary_item = WorkerSalaryItem.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_salary_item }
      end
    end
  
    # GET /worker_salary_items/1/edit
    def edit
      if !params[:salary].nil?
        @worker_salary = WorkerSalary.find(params[:salary])
      end
      @breadcrumb = 'update'
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
    end
  
    # POST /worker_salary_items
    # POST /worker_salary_items.json
    def create
      @breadcrumb = 'create'
      @worker_salary_item = WorkerSalaryItem.new(params[:worker_salary_item])
      @worker_salary_item.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_salary_item.save
          format.html { redirect_to worker_salary_item_path(@worker_salary_item, salary: @worker_salary_item.worker_salary),
                        notice: crud_notice('created', @worker_salary_item) }
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
      @breadcrumb = 'update'
      @worker_salary_item = WorkerSalaryItem.find(params[:id])
      @worker_salary_item.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_salary_item.update_attributes(params[:worker_salary_item])
          format.html { redirect_to worker_salary_item_path(@worker_salary_item, salary: @worker_salary_item.worker_salary),
                        notice: (crud_notice('updated', @worker_salary_item) + "#{undo_link(@worker_salary_item)}").html_safe }
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
      salary = @worker_salary_item.worker_salary
      @worker_salary_item.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_salary_path(salary, item: salary.worker_item),
                    notice: (crud_notice('destroyed', @worker_salary_item) + "#{undo_link(@worker_salary_item)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
