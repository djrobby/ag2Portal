require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerSalariesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /worker_salaries
    # GET /worker_salaries.json
    def index
      @worker_salaries = WorkerSalary.paginate(:page => params[:page], :per_page => per_page).order('year desc')
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_salaries }
      end
    end
  
    # GET /worker_salaries/1
    # GET /worker_salaries/1.json
    def show
      if !params[:item].nil?
        @worker_item = WorkerItem.find(params[:item])
      end
      @breadcrumb = 'read'
      @worker_salary = WorkerSalary.find(params[:id])
      @worker_salary_items = @worker_salary.worker_salary_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_salary }
      end
    end
  
    # GET /worker_salaries/new
    # GET /worker_salaries/new.json
    def new
      if !params[:item].nil?
        @worker_item = WorkerItem.find(params[:item])
      end
      @breadcrumb = 'create'
      @worker_salary = WorkerSalary.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_salary }
      end
    end
  
    # GET /worker_salaries/1/edit
    def edit
      if !params[:item].nil?
        @worker_item = WorkerItem.find(params[:item])
      end
      @breadcrumb = 'update'
      @worker_salary = WorkerSalary.find(params[:id])
    end
  
    # POST /worker_salaries
    # POST /worker_salaries.json
    def create
      @breadcrumb = 'create'
      @worker_salary = WorkerSalary.new(params[:worker_salary])
      @worker_salary.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_salary.save
          format.html { redirect_to worker_salary_path(@worker_salary, item: @worker_salary.worker_item),
                        notice: crud_notice('created', @worker_salary) }
          format.json { render json: @worker_salary, status: :created, location: @worker_salary }
        else
          format.html { render action: "new" }
          format.json { render json: @worker_salary.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /worker_salaries/1
    # PUT /worker_salaries/1.json
    def update
      @breadcrumb = 'update'
      @worker_salary = WorkerSalary.find(params[:id])
      @worker_salary.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @worker_salary.update_attributes(params[:worker_salary])
          format.html { redirect_to worker_salary_path(@worker_salary, item: @worker_salary.worker_item),
                        notice: (crud_notice('updated', @worker_salary) + "#{undo_link(@worker_salary)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @worker_salary.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /worker_salaries/1
    # DELETE /worker_salaries/1.json
    def destroy
      @worker_salary = WorkerSalary.find(params[:id])
      item = @worker_salary.worker_item
      @worker_salary.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_item_path(item, worker: item.worker),
                    notice: (crud_notice('destroyed', @worker_salary) + "#{undo_link(@worker_salary)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
