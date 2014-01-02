require_dependency "ag2_human/application_controller"

module Ag2Human
  class TimerecordTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # GET /timerecord_types
    # GET /timerecord_types.json
    def index
      @timerecord_types = TimerecordType.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @timerecord_types }
      end
    end

    # GET /timerecord_types/1
    # GET /timerecord_types/1.json
    def show
      @breadcrumb = 'read'
      @timerecord_type = TimerecordType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @timerecord_type }
      end
    end

    # GET /timerecord_types/new
    # GET /timerecord_types/new.json
    def new
      @breadcrumb = 'create'
      @timerecord_type = TimerecordType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @timerecord_type }
      end
    end

    # GET /timerecord_types/1/edit
    def edit
      @breadcrumb = 'update'
      @timerecord_type = TimerecordType.find(params[:id])
    end

    # POST /timerecord_types
    # POST /timerecord_types.json
    def create
      @breadcrumb = 'create'
      @timerecord_type = TimerecordType.new(params[:timerecord_type])
      @timerecord_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @timerecord_type.save
          format.html { redirect_to @timerecord_type, notice: crud_notice('created', @timerecord_type) }
          format.json { render json: @timerecord_type, status: :created, location: @timerecord_type }
        else
          format.html { render action: "new" }
          format.json { render json: @timerecord_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /timerecord_types/1
    # PUT /timerecord_types/1.json
    def update
      @breadcrumb = 'update'
      @timerecord_type = TimerecordType.find(params[:id])
      @timerecord_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @timerecord_type.update_attributes(params[:timerecord_type])
          format.html { redirect_to @timerecord_type,
                        notice: (crud_notice('updated', @timerecord_type) + "#{undo_link(@timerecord_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @timerecord_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /timerecord_types/1
    # DELETE /timerecord_types/1.json
    def destroy
      @timerecord_type = TimerecordType.find(params[:id])

      respond_to do |format|
        if @timerecord_type.destroy
          format.html { redirect_to timerecord_types_url,
                      notice: (crud_notice('destroyed', @timerecord_type) + "#{undo_link(@timerecord_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to timerecord_types_url, alert: "#{@timerecord_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @timerecord_type.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
