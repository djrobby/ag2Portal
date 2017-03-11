require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TicketsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ti_update_office_textfield_from_created_by,
                                               :ti_update_office_textfield_from_organization,
                                               :popup_new, :my_tickets,
                                               :tickets_report,
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
    def ti_update_office_textfield_from_created_by
      office = 0
      user = User.find(params[:cb])
      if !user.nil?
        worker = Worker.find_by_user_id(user)
        if !worker.nil?
          office = worker.worker_items.first.office_id if worker.worker_count > 0
        end
      end
      @json_data = { "office" => office }
      render json: @json_data
    end

    # Update office text field at view from organization select
    def ti_update_office_textfield_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @offices = @organization.blank? ? offices_dropdown : Office.joins(:company).where(companies: { organization_id: organization }).order(:name)
        @technicians = @organization.blank? ? technicians_dropdown : @organization.technicians.order(:name)
      else
        @offices = offices_dropdown
        @technicians = technicians_dropdown
      end
      @offices_dropdown = []
      @offices.each do |i|
        @offices_dropdown = @offices_dropdown << [i.id, i.name, i.company.name]
      end
      @json_data = { "offices" => @offices_dropdown, "technicians" => @technicians }
      render json: @json_data
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
      office = params[:OfficeT]
      from = params[:From]
      to = params[:To]
      category = params[:Category]
      priority = params[:Priority]
      status = params[:Status]
      technician = params[:Technician]
      destination = params[:Destination]
      # OCO
      init_oco if !session[:organization]

      @search = Ticket.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
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
        if !destination.blank?
          with :hd_email, destination
        end
        data_accessor_for(Ticket).include = [:creator, :ticket_status, :technician]
        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => per_page
      end

      @tickets = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tickets }
        format.js
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
      @offices = offices_dropdown
      @technicians = technicians_dropdown

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
      @offices = @ticket.organization.blank? ? offices_dropdown : offices_dropdown_edit(@ticket.organization_id)
      @technicians = @ticket.organization.blank? ? technicians_dropdown : @ticket.organization.technicians.order(:name)
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
          @offices = offices_dropdown
          @technicians = technicians_dropdown
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
      if $attachment != nil && !$attachment.avatar.blank? && $attachment.updated_at > @ticket.updated_at
        @ticket.attachment = $attachment.avatar
      end
      if (params[:ticket][:updated_by].blank?)
        params[:ticket][:updated_by] = current_user.id if !current_user.nil?
      end

      respond_to do |format|
        if @ticket.update_attributes(params[:ticket])
          destroy_attachment
          $attachment = nil
          # format.html { redirect_to @ticket, notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          # format.html { redirect_to params[:referrer], notice: I18n.t('activerecord.successful.messages.updated', :model => @ticket.class.model_name.human) }
          format.html { redirect_to params[:referrer],
                        notice: (crud_notice('updated', @ticket) + "#{undo_link(@ticket)}").html_safe }
          format.json { head :no_content }
        else
          destroy_attachment
          $attachment = Attachment.new
          @offices = @ticket.organization.blank? ? offices_dropdown : offices_dropdown_edit(@ticket.organization_id)
          @technicians = @ticket.organization.blank? ? technicians_dropdown : @ticket.organization.technicians.order(:name)
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
      @ticket.organization_id = from_organization

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

    # GET /my_tickets
    # GET /my_tickets.json
    def my_tickets
      user = current_user.id if !current_user.nil?
      # OCO
      init_oco if !session[:organization]

      @search = Ticket.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !user.blank?
          with :created_by, user
        end
        with(:ticket_status_id).less_than(4)
        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => per_page
      end

      @tickets = @search.results

      respond_to do |format|
        format.html # my_tickets.html.erb
        format.json { render json: @tickets }
      end
    end

    # GET /tickets
    # GET /tickets.json
    def tickets_report
      manage_filter_state
      id = params[:Id]
      user = params[:User]
      office = params[:OfficeT]
      from = params[:From]
      to = params[:To]
      category = params[:Category]
      priority = params[:Priority]
      status = params[:Status]
      technician = params[:Technician]
      destination = params[:Destination]
      # OCO
      init_oco if !session[:organization]

      search = Ticket.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
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
        if !destination.blank?
          with :hd_email, destination
        end
        order_by :id, :desc
        paginate :page => params[:page] || 1, :per_page => Ticket.count
      end

      @tickets_report = search.results

      if !@tickets_report.blank?
        title = t("activerecord.models.ticket.few")
        @to = formatted_date(@tickets_report.first.created_at)
        @from = formatted_date(@tickets_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

    private

    def destroy_attachment
      if $attachment != nil
        $attachment.destroy
      end
    end

    def mail_to
      _to = "helpdesk@aguaygestion.com"
      begin
        # OCO company active: e-mail address from company
        if session[:company] != '0'
          company = Company.find(session[:company])
          _to = company.hd_email unless company.nil?
        elsif !current_user.nil?  # e-mail address from current user
          _to = default_mail unless default_mail.nil?
        else  # e-mail address from OCO organization
          if session[:organization] != '0'
            organization = Organization.find(session[:organization])
            _to = organization.hd_email unless organization.nil?
          end
        end
        # Verify _to is ok
        if _to.blank?
          _to = "helpdesk@aguaygestion.com"
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

    def from_organization
      _organization = 0
      begin
        if session[:organization] != '0'
          organization = Organization.find(session[:organization])
          if !organization.nil?
            _organization = organization.id
          end
        end
        if _organization == 0
          _organization = default_organization
        end
      rescue => e
          _office = default_organization
      end
      _organization
    end

    def default_office
      _office = 0
      _user = User.find(current_user)
      if !_user.nil?
        _worker = Worker.find_by_user_id(_user)
        if !_worker.nil?
          _office = _worker.worker_items.first.office_id if _worker.worker_count > 0
        end
      end
      _office
    end

    def default_mail
      _mail = nil
      _user = User.find(current_user)
      if !_user.nil?
        _worker = Worker.find_by_user_id(_user)
        if !_worker.nil?
          _item = _worker.worker_items.first
          if !_item.nil?
            _mail = _item.company.hd_email rescue nil
          end
        end
      end
      _mail
    end

    def default_organization
      _organization = 0
      _user = User.find(current_user)
      if !_user.nil?
        _worker = Worker.find_by_user_id(_user)
        if !_worker.nil?
          _organization = _worker.organization_id
        end
      end
      _organization
    end

    def offices_dropdown
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = session[:organization] != '0' ? Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name) : Office.order(:name)
      end
    end

    def offices_dropdown_edit(_organization)
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = Office.joins(:company).where(companies: { organization_id: _organization }).order(:name)
      end
    end

    def offices_by_company(_company)
      _offices = Office.where(company_id: _company).order(:name)
    end

    def technicians_dropdown
      _technicians = session[:organization] != '0' ? Technician.where(organization_id: session[:organization].to_i).order(:name) : Technician.order(:name)
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
      if params[:OfficeT]
        session[:OfficeT] = params[:OfficeT]
      elsif session[:OfficeT]
        params[:OfficeT] = session[:OfficeT]
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
      # destination
      if params[:Destination]
        session[:Destination] = params[:Destination]
      elsif session[:Destination]
        params[:Destination] = session[:Destination]
      end
    end
  end
end
