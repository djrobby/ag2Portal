require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TicketPrioritiesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /ticket_priorities
    # GET /ticket_priorities.json
    def index
      manage_filter_state
      @ticket_priorities = TicketPriority.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ticket_priorities }
        format.js
      end
    end

    # GET /ticket_priorities/1
    # GET /ticket_priorities/1.json
    def show
      @breadcrumb = 'read'
      @ticket_priority = TicketPriority.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ticket_priority }
      end
    end

    # GET /ticket_priorities/new
    # GET /ticket_priorities/new.json
    def new
      @breadcrumb = 'create'
      @ticket_priority = TicketPriority.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket_priority }
      end
    end

    # GET /ticket_priorities/1/edit
    def edit
      @breadcrumb = 'update'
      @ticket_priority = TicketPriority.find(params[:id])
    end

    # POST /ticket_priorities
    # POST /ticket_priorities.json
    def create
      @breadcrumb = 'create'
      @ticket_priority = TicketPriority.new(params[:ticket_priority])
      @ticket_priority.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket_priority.save
          format.html { redirect_to @ticket_priority, notice: crud_notice('created', @ticket_priority) }
          format.json { render json: @ticket_priority, status: :created, location: @ticket_priority }
        else
          format.html { render action: "new" }
          format.json { render json: @ticket_priority.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /ticket_priorities/1
    # PUT /ticket_priorities/1.json
    def update
      @breadcrumb = 'update'
      @ticket_priority = TicketPriority.find(params[:id])
      @ticket_priority.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket_priority.update_attributes(params[:ticket_priority])
          format.html { redirect_to @ticket_priority,
                        notice: (crud_notice('updated', @ticket_priority) + "#{undo_link(@ticket_priority)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ticket_priority.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /ticket_priorities/1
    # DELETE /ticket_priorities/1.json
    def destroy
      @ticket_priority = TicketPriority.find(params[:id])
      @ticket_priority.destroy

      respond_to do |format|
        format.html { redirect_to ticket_priorities_url,
                      notice: (crud_notice('destroyed', @ticket_priority) + "#{undo_link(@ticket_priority)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      TicketPriority.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
