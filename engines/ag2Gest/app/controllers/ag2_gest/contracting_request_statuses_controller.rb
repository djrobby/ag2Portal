require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestStatusesController < ApplicationController
    # GET /contracting_request_statuses
    # GET /contracting_request_statuses.json
    def index
      @contracting_request_statuses = ContractingRequestStatus.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_request_statuses }
      end
    end
  
    # GET /contracting_request_statuses/1
    # GET /contracting_request_statuses/1.json
    def show
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request_status }
      end
    end
  
    # GET /contracting_request_statuses/new
    # GET /contracting_request_statuses/new.json
    def new
      @contracting_request_status = ContractingRequestStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request_status }
      end
    end
  
    # GET /contracting_request_statuses/1/edit
    def edit
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
    end
  
    # POST /contracting_request_statuses
    # POST /contracting_request_statuses.json
    def create
      @contracting_request_status = ContractingRequestStatus.new(params[:contracting_request_status])
  
      respond_to do |format|
        if @contracting_request_status.save
          format.html { redirect_to @contracting_request_status, notice: 'Contracting request status was successfully created.' }
          format.json { render json: @contracting_request_status, status: :created, location: @contracting_request_status }
        else
          format.html { render action: "new" }
          format.json { render json: @contracting_request_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contracting_request_statuses/1
    # PUT /contracting_request_statuses/1.json
    def update
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
  
      respond_to do |format|
        if @contracting_request_status.update_attributes(params[:contracting_request_status])
          format.html { redirect_to @contracting_request_status, notice: 'Contracting request status was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contracting_request_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contracting_request_statuses/1
    # DELETE /contracting_request_statuses/1.json
    def destroy
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
      @contracting_request_status.destroy
  
      respond_to do |format|
        format.html { redirect_to contracting_request_statuses_url }
        format.json { head :no_content }
      end
    end
  end
end
