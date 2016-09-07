require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestDocumentTypesController < ApplicationController
    # GET /contracting_request_document_types
    # GET /contracting_request_document_types.json
    def index
      @contracting_request_document_types = ContractingRequestDocumentType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_request_document_types }
      end
    end
  
    # GET /contracting_request_document_types/1
    # GET /contracting_request_document_types/1.json
    def show
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request_document_type }
      end
    end
  
    # GET /contracting_request_document_types/new
    # GET /contracting_request_document_types/new.json
    def new
      @contracting_request_document_type = ContractingRequestDocumentType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request_document_type }
      end
    end
  
    # GET /contracting_request_document_types/1/edit
    def edit
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
    end
  
    # POST /contracting_request_document_types
    # POST /contracting_request_document_types.json
    def create
      @contracting_request_document_type = ContractingRequestDocumentType.new(params[:contracting_request_document_type])
  
      respond_to do |format|
        if @contracting_request_document_type.save
          format.html { redirect_to @contracting_request_document_type, notice: 'Contracting request document type was successfully created.' }
          format.json { render json: @contracting_request_document_type, status: :created, location: @contracting_request_document_type }
        else
          format.html { render action: "new" }
          format.json { render json: @contracting_request_document_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contracting_request_document_types/1
    # PUT /contracting_request_document_types/1.json
    def update
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
  
      respond_to do |format|
        if @contracting_request_document_type.update_attributes(params[:contracting_request_document_type])
          format.html { redirect_to @contracting_request_document_type, notice: 'Contracting request document type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contracting_request_document_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contracting_request_document_types/1
    # DELETE /contracting_request_document_types/1.json
    def destroy
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
      @contracting_request_document_type.destroy
  
      respond_to do |format|
        format.html { redirect_to contracting_request_document_types_url }
        format.json { head :no_content }
      end
    end
  end
end
