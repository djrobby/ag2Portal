require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderTypesController < ApplicationController
    # GET /work_order_types
    # GET /work_order_types.json
    def index
      @work_order_types = WorkOrderType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_types }
      end
    end
  
    # GET /work_order_types/1
    # GET /work_order_types/1.json
    def show
      @work_order_type = WorkOrderType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_type }
      end
    end
  
    # GET /work_order_types/new
    # GET /work_order_types/new.json
    def new
      @work_order_type = WorkOrderType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_type }
      end
    end
  
    # GET /work_order_types/1/edit
    def edit
      @work_order_type = WorkOrderType.find(params[:id])
    end
  
    # POST /work_order_types
    # POST /work_order_types.json
    def create
      @work_order_type = WorkOrderType.new(params[:work_order_type])
  
      respond_to do |format|
        if @work_order_type.save
          format.html { redirect_to @work_order_type, notice: 'Work order type was successfully created.' }
          format.json { render json: @work_order_type, status: :created, location: @work_order_type }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_order_types/1
    # PUT /work_order_types/1.json
    def update
      @work_order_type = WorkOrderType.find(params[:id])
  
      respond_to do |format|
        if @work_order_type.update_attributes(params[:work_order_type])
          format.html { redirect_to @work_order_type, notice: 'Work order type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_order_types/1
    # DELETE /work_order_types/1.json
    def destroy
      @work_order_type = WorkOrderType.find(params[:id])
      @work_order_type.destroy
  
      respond_to do |format|
        format.html { redirect_to work_order_types_url }
        format.json { head :no_content }
      end
    end
  end
end
