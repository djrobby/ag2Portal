require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderStatusesController < ApplicationController
    # GET /work_order_statuses
    # GET /work_order_statuses.json
    def index
      @work_order_statuses = WorkOrderStatus.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_statuses }
      end
    end
  
    # GET /work_order_statuses/1
    # GET /work_order_statuses/1.json
    def show
      @work_order_status = WorkOrderStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_status }
      end
    end
  
    # GET /work_order_statuses/new
    # GET /work_order_statuses/new.json
    def new
      @work_order_status = WorkOrderStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_status }
      end
    end
  
    # GET /work_order_statuses/1/edit
    def edit
      @work_order_status = WorkOrderStatus.find(params[:id])
    end
  
    # POST /work_order_statuses
    # POST /work_order_statuses.json
    def create
      @work_order_status = WorkOrderStatus.new(params[:work_order_status])
  
      respond_to do |format|
        if @work_order_status.save
          format.html { redirect_to @work_order_status, notice: 'Work order status was successfully created.' }
          format.json { render json: @work_order_status, status: :created, location: @work_order_status }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_order_statuses/1
    # PUT /work_order_statuses/1.json
    def update
      @work_order_status = WorkOrderStatus.find(params[:id])
  
      respond_to do |format|
        if @work_order_status.update_attributes(params[:work_order_status])
          format.html { redirect_to @work_order_status, notice: 'Work order status was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_order_statuses/1
    # DELETE /work_order_statuses/1.json
    def destroy
      @work_order_status = WorkOrderStatus.find(params[:id])
      @work_order_status.destroy
  
      respond_to do |format|
        format.html { redirect_to work_order_statuses_url }
        format.json { head :no_content }
      end
    end
  end
end
