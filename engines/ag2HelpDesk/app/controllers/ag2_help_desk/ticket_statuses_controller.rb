require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TicketStatusesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /ticket_statuses
    # GET /ticket_statuses.json
    def index
      manage_filter_state
      @ticket_statuses = TicketStatus.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ticket_statuses }
        format.js
      end
    end

    # GET /ticket_statuses/1
    # GET /ticket_statuses/1.json
    def show
      @breadcrumb = 'read'
      @ticket_status = TicketStatus.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ticket_status }
      end
    end

    # GET /ticket_statuses/new
    # GET /ticket_statuses/new.json
    def new
      @breadcrumb = 'create'
      @ticket_status = TicketStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket_status }
      end
    end

    # GET /ticket_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @ticket_status = TicketStatus.find(params[:id])
    end

    # POST /ticket_statuses
    # POST /ticket_statuses.json
    def create
      @breadcrumb = 'create'
      @ticket_status = TicketStatus.new(params[:ticket_status])
      @ticket_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket_status.save
          format.html { redirect_to @ticket_status, notice: crud_notice('created', @ticket_status) }
          format.json { render json: @ticket_status, status: :created, location: @ticket_status }
        else
          format.html { render action: "new" }
          format.json { render json: @ticket_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /ticket_statuses/1
    # PUT /ticket_statuses/1.json
    def update
      @breadcrumb = 'update'
      @ticket_status = TicketStatus.find(params[:id])
      @ticket_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket_status.update_attributes(params[:ticket_status])
          format.html { redirect_to @ticket_status,
                        notice: (crud_notice('updated', @ticket_status) + "#{undo_link(@ticket_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ticket_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /ticket_statuses/1
    # DELETE /ticket_statuses/1.json
    def destroy
      @ticket_status = TicketStatus.find(params[:id])
      @ticket_status.destroy

      respond_to do |format|
        format.html { redirect_to ticket_statuses_url,
                      notice: (crud_notice('destroyed', @ticket_status) + "#{undo_link(@ticket_status)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      TicketStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
