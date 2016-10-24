require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestDocumentTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /contracting_request_document_types
    # GET /contracting_request_document_types.json
    def index

      manage_filter_state
      @contracting_request_document_types = ContractingRequestDocumentType.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_request_document_types }
        format.js
      end
    end

    # GET /contracting_request_document_types/1
    # GET /contracting_request_document_types/1.json
    def show
      @breadcrumb = 'read'
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request_document_type }
      end
    end

    # GET /contracting_request_document_types/new
    # GET /contracting_request_document_types/new.json
    def new
      @breadcrumb = 'create'
      @contracting_request_document_type = ContractingRequestDocumentType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request_document_type }
      end
    end

    # GET /contracting_request_document_types/1/edit
    def edit
      @breadcrumb = 'update'
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
    end

    # POST /contracting_request_document_types
    # POST /contracting_request_document_types.json
    def create
      @breadcrumb = 'create'
      @contracting_request_document_type = ContractingRequestDocumentType.new(params[:contracting_request_document_type])
      @contracting_request_document_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_document_type.save
          format.html { redirect_to @contracting_request_document_type, notice: t('activerecord.attributes.contracting_request_document_type.create') }
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
      @breadcrumb = 'update'
      @contracting_request_document_type = ContractingRequestDocumentType.find(params[:id])
      @contracting_request_document_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_document_type.update_attributes(params[:contracting_request_document_type])
          format.html { redirect_to @contracting_request_document_type, notice: t('activerecord.attributes.contracting_request_document_type.successfully') }
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

    private

    def sort_column
      ContractingRequestDocumentType.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    # Keeps filter state
    def manage_filter_state
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end

  end
end
