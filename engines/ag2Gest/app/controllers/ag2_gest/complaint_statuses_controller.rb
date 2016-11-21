require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintStatusesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /complaint_statuses
    # GET /complaint_statuses.json
    def index
      manage_filter_state
      @complaint_statuses = ComplaintStatus.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_statuses }
        format.js
      end
    end

    # GET /complaint_statuses/1
    # GET /complaint_statuses/1.json
    def show
      @breadcrumb = 'read'
      @complaint_status = ComplaintStatus.find(params[:id])
      @complaints = @complaint_status.complaints.by_no

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_status }
      end
    end

    # GET /complaint_statuses/new
    # GET /complaint_statuses/new.json
    def new
      @breadcrumb = 'create'
      @complaint_status = ComplaintStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_status }
      end
    end

    # GET /complaint_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @complaint_status = ComplaintStatus.find(params[:id])
    end

    # POST /complaint_statuses
    # POST /complaint_statuses.json
    def create
      @breadcrumb = 'create'
      @complaint_status = ComplaintStatus.new(params[:complaint_status])
      @complaint_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @complaint_status.save
          format.html { redirect_to @complaint_status, notice: crud_notice('created', @complaint_status) }
          format.json { render json: @complaint_status, status: :created, location: @complaint_status }
        else
          format.html { render action: "new" }
          format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /complaint_statuses/1
    # PUT /complaint_statuses/1.json
    def update
      @breadcrumb = 'update'
      @complaint_status = ComplaintStatus.find(params[:id])
      @complaint_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @complaint_status.update_attributes(params[:complaint_status])
          format.html { redirect_to @complaint_status,
                        notice: (crud_notice('updated', @complaint_status) + "#{undo_link(@complaint_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /complaint_statuses/1
    # DELETE /complaint_statuses/1.json
    def destroy
      @complaint_status = ComplaintStatus.find(params[:id])

      respond_to do |format|
        if @complaint_status.destroy
          format.html { redirect_to complaint_statuses_url,
                      notice: (crud_notice('destroyed', @complaint_status) + "#{undo_link(@complaint_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to complaint_statuses_url, alert: "#{@complaint_status.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ComplaintStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
