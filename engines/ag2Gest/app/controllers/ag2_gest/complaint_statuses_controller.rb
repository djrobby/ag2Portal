require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintStatusesController < ApplicationController
    # GET /complaint_statuses
    # GET /complaint_statuses.json
    def index
      @complaint_statuses = ComplaintStatus.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_statuses }
      end
    end
  
    # GET /complaint_statuses/1
    # GET /complaint_statuses/1.json
    def show
      @complaint_status = ComplaintStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_status }
      end
    end
  
    # GET /complaint_statuses/new
    # GET /complaint_statuses/new.json
    def new
      @complaint_status = ComplaintStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_status }
      end
    end
  
    # GET /complaint_statuses/1/edit
    def edit
      @complaint_status = ComplaintStatus.find(params[:id])
    end
  
    # POST /complaint_statuses
    # POST /complaint_statuses.json
    def create
      @complaint_status = ComplaintStatus.new(params[:complaint_status])
  
      respond_to do |format|
        if @complaint_status.save
          format.html { redirect_to @complaint_status, notice: 'Complaint status was successfully created.' }
          format.json { render json: @complaint_status, status: :created, location: @complaint_status }
        else
          format.html { render action: "new" }
          format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /complaint_statuses/1
    # PUT /complaint_statuses/1.json
    def update
      @complaint_status = ComplaintStatus.find(params[:id])
  
      respond_to do |format|
        if @complaint_status.update_attributes(params[:complaint_status])
          format.html { redirect_to @complaint_status, notice: 'Complaint status was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /complaint_statuses/1
    # DELETE /complaint_statuses/1.json
    def destroy
      @complaint_status = ComplaintStatus.find(params[:id])
      @complaint_status.destroy
  
      respond_to do |format|
        format.html { redirect_to complaint_statuses_url }
        format.json { head :no_content }
      end
    end
  end
end
