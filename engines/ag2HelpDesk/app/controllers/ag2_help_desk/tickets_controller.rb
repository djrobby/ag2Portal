require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TicketsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_office_textfield_from_created_by]
    
    # Update office text field at view from created_by select
    def update_office_textfield_from_created_by
      office = 0

      user = User.find(params[:id])
      if !user.nil?
        worker = Worker.find_by_user_id(user)
        if !worker.nil?
        office = worker.office_id
        end
      end

      @json_data = { "office" => office }

      respond_to do |format|
        format.html # update_office_textfield_from_created_by.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /tickets
    # GET /tickets.json
    def index
      user = params[:User]
      office = params[:Office]
      from = params[:From]
      to = params[:To]
      category = params[:Category]
      priority = params[:Priority]
      status = params[:Status]
      technician = params[:Technician]

      @search = Ticket.search do
        fulltext params[:search]

        if !user.blank?
          with :created_by, user
        end
        if !office.blank?
          with :office_id, office
        end
        if !from.blank?
          any_of do
            with(:created_at).greater_than(from)
            with :created_at, from
          end
        end
        if !to.blank?
          any_of do
            with(:created_at).less_than(to)
            with :created_at, to
          end
        end
        if !category.blank?
          with :ticket_category_id, category
        end
        if !priority.blank?
          with :ticket_priority_id, priority
        end
        if !status.blank?
          with :ticket_status_id, status
        end
        if !technician.blank?
          with :technician_id, technician
        end

        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => per_page
      end

      @tickets = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tickets }
      end
    end

    # GET /tickets/1
    # GET /tickets/1.json
    def show
      @breadcrumb = 'read'
      @ticket = Ticket.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ticket }
      end
    end

    # GET /tickets/new
    # GET /tickets/new.json
    def new
      @breadcrumb = 'create'
      @ticket = Ticket.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket }
      end
    end

    # GET /tickets/1/edit
    def edit
      @breadcrumb = 'update'
      @ticket = Ticket.find(params[:id])
    end

    # POST /tickets
    # POST /tickets.json
    def create
      @breadcrumb = 'create'
      @ticket = Ticket.new(params[:ticket])
      @ticket.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket.save
          format.html { redirect_to @ticket, notice: crud_notice('created', @ticket) }
          format.json { render json: @ticket, status: :created, location: @ticket }
        else
          format.html { render action: "new" }
          format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /tickets/1
    # PUT /tickets/1.json
    def update
      @breadcrumb = 'update'
      @ticket = Ticket.find(params[:id])
      @ticket.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @ticket.update_attributes(params[:ticket])
          # format.html { redirect_to @ticket, notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          # format.html { redirect_to params[:referrer], notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          format.html { redirect_to params[:referrer],
                        notice: (crud_notice('updated', @ticket) + "#{undo_link(@ticket)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tickets/1
    # DELETE /tickets/1.json
    def destroy
      @ticket = Ticket.find(params[:id])
      @ticket.destroy

      respond_to do |format|
        format.html { redirect_to tickets_url,
                      notice: (crud_notice('destroyed', @ticket) + "#{undo_link(@ticket)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
