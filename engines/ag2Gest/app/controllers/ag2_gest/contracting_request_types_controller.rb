require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractingRequestTypesController < ApplicationController

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /contracting_request_types
    # GET /contracting_request_types.json
    def index
      manage_filter_state
      @contracting_request_types = ContractingRequestType.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contracting_request_types }
        format.js
      end
    end

    # GET /contracting_request_types/1
    # GET /contracting_request_types/1.json
    def show
      @breadcrumb = 'read'
      @contracting_request_type = ContractingRequestType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contracting_request_type }
      end
    end

    # GET /contracting_request_types/new
    # GET /contracting_request_types/new.json
    def new
      @breadcrumb = 'create'
      @contracting_request_type = ContractingRequestType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contracting_request_type }
      end
    end

    # GET /contracting_request_types/1/edit
    def edit
      @breadcrumb = 'update'
      @contracting_request_type = ContractingRequestType.find(params[:id])
    end

    # POST /contracting_request_types
    # POST /contracting_request_types.json
    def create
      @breadcrumb = 'create'
      @contracting_request_type = ContractingRequestType.new(params[:contracting_request_type])
      @contracting_request_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_type.save
          format.html { redirect_to @contracting_request_type, notice: t('activerecord.attributes.contracting_request_type.create') }
          format.json { render json: @contracting_request_type, status: :created, location: @contracting_request_type }
        else
          format.html { render action: "new" }
          format.json { render json: @contracting_request_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /contracting_request_types/1
    # PUT /contracting_request_types/1.json
    def update
      @breadcrumb = 'update'
      @contracting_request_type = ContractingRequestType.find(params[:id])
      @contracting_request_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contracting_request_type.update_attributes(params[:contracting_request_type])
          format.html { redirect_to @contracting_request_type,
                        notice: (crud_notice('updated', @contracting_request_type) + "#{undo_link(@contracting_request_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contracting_request_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /contracting_request_types/1
    # DELETE /contracting_request_types/1.json
    def destroy
      @contracting_request_type = ContractingRequestType.find(params[:id])
      respond_to do |format|
        if @contracting_request_type.destroy
          format.html { redirect_to contracting_request_types_url,
                      notice: (crud_notice('destroyed', @contracting_request_type) + "#{undo_link(@contracting_request_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to contracting_request_types_url, alert: "#{@contracting_request_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @contracting_request_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ContractingRequestType.column_names.include?(params[:sort]) ? params[:sort] : "description"
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
