require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkerSalariesController < ApplicationController
    # GET /worker_salaries
    # GET /worker_salaries.json
    def index
      @worker_salaries = WorkerSalary.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @worker_salaries }
      end
    end
  
    # GET /worker_salaries/1
    # GET /worker_salaries/1.json
    def show
      @worker_salary = WorkerSalary.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker_salary }
      end
    end
  
    # GET /worker_salaries/new
    # GET /worker_salaries/new.json
    def new
      @worker_salary = WorkerSalary.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker_salary }
      end
    end
  
    # GET /worker_salaries/1/edit
    def edit
      @worker_salary = WorkerSalary.find(params[:id])
    end
  
    # POST /worker_salaries
    # POST /worker_salaries.json
    def create
      @worker_salary = WorkerSalary.new(params[:worker_salary])
  
      respond_to do |format|
        if @worker_salary.save
          format.html { redirect_to @worker_salary, notice: 'Worker salary was successfully created.' }
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
      @worker_salary = WorkerSalary.find(params[:id])
  
      respond_to do |format|
        if @worker_salary.update_attributes(params[:worker_salary])
          format.html { redirect_to @worker_salary, notice: 'Worker salary was successfully updated.' }
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
      @worker_salary.destroy
  
      respond_to do |format|
        format.html { redirect_to worker_salaries_url }
        format.json { head :no_content }
      end
    end
  end
end
