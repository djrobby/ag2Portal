require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TicketsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_office_textfield_from_created_by,
                                               :popup_new,
                                               :ti_update_attachment]
    # Public attachment for drag&drop
    $attachment = nil
  
    # Update attached file from drag&drop
    def ti_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment.avatar = params[:file]
      $attachment.id = 1
      $attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end
    
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
      manage_filter_state
      id = params[:Id]
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
        if !id.blank?
          with :id, id
        end
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
      $attachment = Attachment.new
      destroy_attachment

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket }
      end
    end

    # GET /tickets/1/edit
    def edit
      @breadcrumb = 'update'
      @ticket = Ticket.find(params[:id])
      $attachment = Attachment.new
      destroy_attachment
    end

    # POST /tickets
    # POST /tickets.json
    def create
      @breadcrumb = 'create'
      @ticket = Ticket.new(params[:ticket])
      @ticket.created_by = current_user.id if !current_user.nil?
      @ticket.source_ip = request.remote_ip
      @ticket.hd_email = mail_to
      @ticket.office_id = from_office
      # Should use attachment from drag&drop?
      if @ticket.attachment.blank? && !$attachment.avatar.blank?
        @ticket.attachment = $attachment.avatar
      end

      respond_to do |format|
        if @ticket.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @ticket, notice: crud_notice('created', @ticket) }
          format.json { render json: @ticket, status: :created, location: @ticket }
        else
          $attachment.destroy
          $attachment = Attachment.new
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
      # Should use attachment from drag&drop?
      if !$attachment.avatar.blank? && $attachment.updated_at > @ticket.updated_at
        @ticket.attachment = $attachment.avatar
      end

      respond_to do |format|
        if @ticket.update_attributes(params[:ticket])
          $attachment.destroy
          $attachment = nil
          # format.html { redirect_to @ticket, notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          # format.html { redirect_to params[:referrer], notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          format.html { redirect_to params[:referrer],
                        notice: (crud_notice('updated', @ticket) + "#{undo_link(@ticket)}").html_safe }
          format.json { head :no_content }
        else
          $attachment.destroy
          $attachment = Attachment.new
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

    # POST /tickets/popup_new
    # POST /tickets/popup_new.json
    def popup_new
      @breadcrumb = 'create'
      @ticket = Ticket.new(params[:ticket])
      @ticket.created_by = current_user.id if !current_user.nil?
      @ticket.source_ip = request.remote_ip
      @ticket.hd_email = mail_to
      @ticket.office_id = from_office

      respond_to do |format|
        if @ticket.save
          format.html { redirect_to params[:referrer] }
          format.json { render json: @ticket, status: :created, location: @ticket }
        else
          format.html { redirect_to params[:referrer], notice: I18n.t('activerecord.errors.ticket.popup') }
          format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
      end
    end
    
    private
    
    def mail_to
      _to = "helpdesk@aguaygestion.com"
      begin
        if session[:company] != '0'
          company = Company.find(session[:company])
          if !company.nil?
            _to = company.hd_email
          end
        end
      rescue => e
        _to = "helpdesk@aguaygestion.com"
      end
      _to
    end

    def from_office
      _office = 0
      begin
        if session[:office] != '0'
          office = Office.find(session[:office])
          if !office.nil?
            _office = office.id
          end
        end
        if _office == 0
          _office = default_office
        end
      rescue => e
          _office = default_office
      end
      _office
    end
    
    def default_office
      _office = 0
      _user = User.find(current_user)
      if !_user.nil?
        _worker = Worker.find_by_user_id(_user)
        if !_worker.nil?
          _office = _worker.worker_items.first.office_id if _worker.worker_items.count > 0
        end
      end
      _office
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # id
      if params[:Id]
        session[:Id] = params[:Id]
      elsif session[:Id]
        params[:Id] = session[:Id]
      end
      # user
      if params[:User]
        session[:User] = params[:User]
      elsif session[:User]
        params[:User] = session[:User]
      end
      # office
      if params[:Office]
        session[:Office] = params[:Office]
      elsif session[:Office]
        params[:Office] = session[:Office]
      end
      # from
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end
      # to
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end
      # category
      if params[:Category]
        session[:Category] = params[:Category]
      elsif session[:Category]
        params[:Category] = session[:Category]
      end
      # priority
      if params[:Priority]
        session[:Priority] = params[:Priority]
      elsif session[:Priority]
        params[:Priority] = session[:Priority]
      end
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
      # technician
      if params[:Technician]
        session[:Technician] = params[:Technician]
      elsif session[:Technician]
        params[:Technician] = session[:Technician]
      end
    end
  end
end
