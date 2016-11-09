require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintDocumentTypesController < ApplicationController
    # GET /complaint_document_types
    # GET /complaint_document_types.json
    def index
      @complaint_document_types = ComplaintDocumentType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_document_types }
      end
    end
  
    # GET /complaint_document_types/1
    # GET /complaint_document_types/1.json
    def show
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_document_type }
      end
    end
  
    # GET /complaint_document_types/new
    # GET /complaint_document_types/new.json
    def new
      @complaint_document_type = ComplaintDocumentType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_document_type }
      end
    end
  
    # GET /complaint_document_types/1/edit
    def edit
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
    end
  
    # POST /complaint_document_types
    # POST /complaint_document_types.json
    def create
      @complaint_document_type = ComplaintDocumentType.new(params[:complaint_document_type])
  
      respond_to do |format|
        if @complaint_document_type.save
          format.html { redirect_to @complaint_document_type, notice: 'Complaint document type was successfully created.' }
          format.json { render json: @complaint_document_type, status: :created, location: @complaint_document_type }
        else
          format.html { render action: "new" }
          format.json { render json: @complaint_document_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /complaint_document_types/1
    # PUT /complaint_document_types/1.json
    def update
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
  
      respond_to do |format|
        if @complaint_document_type.update_attributes(params[:complaint_document_type])
          format.html { redirect_to @complaint_document_type, notice: 'Complaint document type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @complaint_document_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /complaint_document_types/1
    # DELETE /complaint_document_types/1.json
    def destroy
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
      @complaint_document_type.destroy
  
      respond_to do |format|
        format.html { redirect_to complaint_document_types_url }
        format.json { head :no_content }
      end
    end
  end
end
