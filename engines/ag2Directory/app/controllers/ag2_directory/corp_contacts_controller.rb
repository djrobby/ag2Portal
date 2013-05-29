require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class CorpContactsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => :update_company_textfield_from_office
    # Update company text field at view from office select
    def update_company_textfield_from_office
      @office = Office.find(params[:id])
      @company = Company.find(@office.company)

      respond_to do |format|
        format.html # update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end

    #
    # Advanced searchers
    # DO NOT use strings as queries to avoid SQL injection exploits!
    #
    # Search contacts
    def search
      letter = params[:letter]

      @search = CorpContact.search do
        fulltext params[:search]
        order_by :last_name, :asc
        order_by :first_name, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      if letter.blank? || letter == "%"
        @corp_contacts = @search.results
      else
        @corp_contacts = CorpContact.where("last_name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('last_name, first_name')
      end

      respond_to do |format|
        format.html # search.html.erb
        format.json { render json: @corp_contacts }
      end
    end

    #
    # Default Methods
    #
    # GET /corp_contacts
    # GET /corp_contacts.json
    def index
      #@corp_contacts = CorpContact.all
      @corp_contacts = Company.order('name').all(:include => [:offices, :corp_contacts])

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @corp_contacts }
      end
    end

    # GET /corp_contacts/1
    # GET /corp_contacts/1.json
    def show
      @breadcrumb = 'read'
      @corp_contact = CorpContact.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @corp_contact }
      end
    end

    # GET /corp_contacts/new
    # GET /corp_contacts/new.json
    def new
      @breadcrumb = 'create'
      @corp_contact = CorpContact.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @corp_contact }
      end
    end

    # GET /corp_contacts/1/edit
    def edit
      @breadcrumb = 'update'
      @corp_contact = CorpContact.find(params[:id])
    end

    # POST /corp_contacts
    # POST /corp_contacts.json
    def create
      @breadcrumb = 'create'
      @corp_contact = CorpContact.new(params[:corp_contact])
      @corp_contact.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @corp_contact.save
          format.html { redirect_to @corp_contact, notice: I18n.t('activerecord.successful.messages.created', :model => @corp_contact.class.model_name.human) }
          format.json { render json: @corp_contact, status: :created, location: @corp_contact }
        else
          format.html { render action: "new" }
          format.json { render json: @corp_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /corp_contacts/1
    # PUT /corp_contacts/1.json
    def update
      @breadcrumb = 'update'
      @corp_contact = CorpContact.find(params[:id])
      @corp_contact.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @corp_contact.update_attributes(params[:corp_contact])
          format.html { redirect_to @corp_contact,
                        notice: (I18n.t('activerecord.successful.messages.updated', :model => @corp_contact.class.model_name.human) +
                        "#{undo_link(@corp_contact)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @corp_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /corp_contacts/1
    # DELETE /corp_contacts/1.json
    def destroy
      @corp_contact = CorpContact.find(params[:id])
      @corp_contact.destroy

      respond_to do |format|
        format.html { redirect_to corp_contacts_url,
                      notice: (I18n.t('activerecord.successful.messages.destroyed', :model => @corp_contact.class.model_name.human) +
                      "#{undo_link(@corp_contact)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
