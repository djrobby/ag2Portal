require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderLaborsController < ApplicationController
    # GET /work_order_labors
    # GET /work_order_labors.json
    def index
      @work_order_labors = WorkOrderLabor.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_labors }
      end
    end
  
    # GET /work_order_labors/1
    # GET /work_order_labors/1.json
    def show
      @work_order_labor = WorkOrderLabor.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_labor }
      end
    end
  
    # GET /work_order_labors/new
    # GET /work_order_labors/new.json
    def new
      @work_order_labor = WorkOrderLabor.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_labor }
      end
    end
  
    # GET /work_order_labors/1/edit
    def edit
      @work_order_labor = WorkOrderLabor.find(params[:id])
    end
  
    # POST /work_order_labors
    # POST /work_order_labors.json
    def create
      @work_order_labor = WorkOrderLabor.new(params[:work_order_labor])
  
      respond_to do |format|
        if @work_order_labor.save
          format.html { redirect_to @work_order_labor, notice: 'Work order labor was successfully created.' }
          format.json { render json: @work_order_labor, status: :created, location: @work_order_labor }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_labor.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_order_labors/1
    # PUT /work_order_labors/1.json
    def update
      @work_order_labor = WorkOrderLabor.find(params[:id])
  
      respond_to do |format|
        if @work_order_labor.update_attributes(params[:work_order_labor])
          format.html { redirect_to @work_order_labor, notice: 'Work order labor was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_labor.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_order_labors/1
    # DELETE /work_order_labors/1.json
    def destroy
      @work_order_labor = WorkOrderLabor.find(params[:id])
      @work_order_labor.destroy
  
      respond_to do |format|
        format.html { redirect_to work_order_labors_url }
        format.json { head :no_content }
      end
    end
  end
end
