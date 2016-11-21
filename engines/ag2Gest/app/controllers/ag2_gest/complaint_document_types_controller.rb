require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintDocumentTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /complaint_document_types
    # GET /complaint_document_types.json
    def index
      manage_filter_state
      @complaint_document_types = ComplaintDocumentType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_document_types }
        format.js
      end
    end

    # GET /complaint_document_types/1
    # GET /complaint_document_types/1.json
    def show
      @breadcrumb = 'read'
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
      @complaint_documents = @complaint_document_type.complaint_documents

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_document_type }
      end
    end

    # GET /complaint_document_types/new
    # GET /complaint_document_types/new.json
    def new
      @breadcrumb = 'create'
      @complaint_document_type = ComplaintDocumentType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_document_type }
      end
    end

    # GET /complaint_document_types/1/edit
    def edit
      @breadcrumb = 'update'
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
    end

    # POST /complaint_document_types
    # POST /complaint_document_types.json
    def create
      @breadcrumb = 'create'
      @complaint_document_type = ComplaintDocumentType.new(params[:complaint_document_type])
      @complaint_document_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @complaint_document_type.save
          format.html { redirect_to @complaint_document_type, notice: crud_notice('created', @complaint_document_type) }
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
      @breadcrumb = 'update'
      @complaint_document_type = ComplaintDocumentType.find(params[:id])
      @complaint_document_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @complaint_document_type.update_attributes(params[:complaint_document_type])
          format.html { redirect_to @complaint_document_type,
                        notice: (crud_notice('updated', @complaint_document_type) + "#{undo_link(@complaint_document_type)}").html_safe }
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

      respond_to do |format|
        if @complaint_document_type.destroy
          format.html { redirect_to complaint_document_types_url,
                      notice: (crud_notice('destroyed', @complaint_document_type) + "#{undo_link(@complaint_document_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to complaint_document_types_url, alert: "#{@complaint_document_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @complaint_document_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ComplaintDocumentType.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
