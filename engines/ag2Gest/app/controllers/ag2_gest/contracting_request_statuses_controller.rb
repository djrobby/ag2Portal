require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestStatusesController < ApplicationController

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /contracting_request_statuses
    # GET /contracting_request_statuses.json
    def index
      manage_filter_state
      @contracting_request_statuses = ContractingRequestStatus.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_request_statuses }
        format.js
      end
    end

    # GET /contracting_request_statuses/1
    # GET /contracting_request_statuses/1.json
    def show
      @breadcrumb = 'read'
      @contracting_request_status = ContractingRequestStatus.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request_status }
      end
    end

    # GET /contracting_request_statuses/new
    # GET /contracting_request_statuses/new.json
    def new

      @breadcrumb = 'create'
      @contracting_request_status = ContractingRequestStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request_status }
      end
    end

    # GET /contracting_request_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
    end

    # POST /contracting_request_statuses
    # POST /contracting_request_statuses.json
    def create
      @breadcrumb = 'create'
      @contracting_request_status = ContractingRequestStatus.new(params[:contracting_request_status])
      @contracting_request_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_status.save
          format.html { redirect_to @contracting_request_status, notice: t('activerecord.attributes.contracting_request_status.create') }
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
      @breadcrumb = 'update'
      @contracting_request_status = ContractingRequestStatus.find(params[:id])
      @contracting_request_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_status.update_attributes(params[:contracting_request_status])
          format.html { redirect_to @contracting_request_status, notice: t('activerecord.attributes.contracting_request_status.successfully') }
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

    private

    def sort_column
      ContractingRequestStatus.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
