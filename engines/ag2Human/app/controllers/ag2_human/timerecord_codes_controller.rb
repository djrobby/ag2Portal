require_dependency "ag2_human/application_controller"

module Ag2Human
  class TimerecordCodesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /timerecord_codes
    # GET /timerecord_codes.json
    def index
      @timerecord_codes = TimerecordCode.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @timerecord_codes }
      end
    end

    # GET /timerecord_codes/1
    # GET /timerecord_codes/1.json
    def show
      @breadcrumb = 'read'
      @timerecord_code = TimerecordCode.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @timerecord_code }
      end
    end

    # GET /timerecord_codes/new
    # GET /timerecord_codes/new.json
    def new
      @breadcrumb = 'create'
      @timerecord_code = TimerecordCode.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @timerecord_code }
      end
    end

    # GET /timerecord_codes/1/edit
    def edit
      @breadcrumb = 'update'
      @timerecord_code = TimerecordCode.find(params[:id])
    end

    # POST /timerecord_codes
    # POST /timerecord_codes.json
    def create
      @breadcrumb = 'create'
      @timerecord_code = TimerecordCode.new(params[:timerecord_code])
      @timerecord_code.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @timerecord_code.save
          format.html { redirect_to @timerecord_code, notice: crud_notice('created', @timerecord_code) }
          format.json { render json: @timerecord_code, status: :created, location: @timerecord_code }
        else
          format.html { render action: "new" }
          format.json { render json: @timerecord_code.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /timerecord_codes/1
    # PUT /timerecord_codes/1.json
    def update
      @breadcrumb = 'update'
      @timerecord_code = TimerecordCode.find(params[:id])
      @timerecord_code.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @timerecord_code.update_attributes(params[:timerecord_code])
          format.html { redirect_to @timerecord_code,
                        notice: (crud_notice('updated', @timerecord_code) + "#{undo_link(@timerecord_code)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @timerecord_code.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /timerecord_codes/1
    # DELETE /timerecord_codes/1.json
    def destroy
      @timerecord_code = TimerecordCode.find(params[:id])

      respond_to do |format|
        if @timerecord_code.destroy
          format.html { redirect_to timerecord_codes_url,
                      notice: (crud_notice('destroyed', @timerecord_code) + "#{undo_link(@timerecord_code)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to timerecord_codes_url, alert: "#{@timerecord_code.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @timerecord_code.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      TimerecordCode.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end
