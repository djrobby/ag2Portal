require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestsController < ApplicationController
    # GET /contracting_requests
    # GET /contracting_requests.json
    def index
      @contracting_requests = ContractingRequest.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_requests }
      end
    end
  
    # GET /contracting_requests/1
    # GET /contracting_requests/1.json
    def show
      @contracting_request = ContractingRequest.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request }
      end
    end
  
    # GET /contracting_requests/new
    # GET /contracting_requests/new.json
    def new
      @contracting_request = ContractingRequest.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request }
      end
    end
  
    # GET /contracting_requests/1/edit
    def edit
      @contracting_request = ContractingRequest.find(params[:id])
    end
  
    # POST /contracting_requests
    # POST /contracting_requests.json
    def create
      @contracting_request = ContractingRequest.new(params[:contracting_request])
  
      respond_to do |format|
        if @contracting_request.save
          format.html { redirect_to @contracting_request, notice: 'Contracting request was successfully created.' }
          format.json { render json: @contracting_request, status: :created, location: @contracting_request }
        else
          format.html { render action: "new" }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contracting_requests/1
    # PUT /contracting_requests/1.json
    def update
      @contracting_request = ContractingRequest.find(params[:id])
  
      respond_to do |format|
        if @contracting_request.update_attributes(params[:contracting_request])
          format.html { redirect_to @contracting_request, notice: 'Contracting request was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contracting_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contracting_requests/1
    # DELETE /contracting_requests/1.json
    def destroy
      @contracting_request = ContractingRequest.find(params[:id])
      @contracting_request.destroy
  
      respond_to do |format|
        format.html { redirect_to contracting_requests_url }
        format.json { head :no_content }
      end
    end
  end
end
