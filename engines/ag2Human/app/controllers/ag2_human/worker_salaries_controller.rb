require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerSalariesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ws_update_amounts]

    # Update cost text field at view (formatting)
    def ws_update_amounts
      gs = params[:gs].to_f / 100
      vs = params[:vs].to_f / 100
      ss = params[:ss].to_f / 100
      dp = params[:dp].to_f / 100
      ot = params[:ot].to_f / 100
      # Format number
      gs = number_with_precision(gs.round(2), precision: 2)
      vs = number_with_precision(vs.round(2), precision: 2)
      ss = number_with_precision(ss.round(2), precision: 2)
      dp = number_with_precision(dp.round(2), precision: 2)
      ot = number_with_precision(ot.round(2), precision: 2)
      # Setup JSON
      @json_data = { "gs" => gs.to_s, "vs" => vs.to_s, "ss" => ss.to_s, "dp" => dp.to_s, "ot" => ot.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
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
