require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierContactsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /supplier_contacts
    # GET /supplier_contacts.json
    def index
      # filters keep unmodified, only if the calling view (referrer) belongs to this controller
      if (request.referrer.exclude? "ag2_purchase") || (request.referrer.exclude? "supplier_contacts")
        reset_session_variables_for_filters
      end

      manage_filter_state
      supplier = params[:Supplier]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @suppliers = suppliers_dropdown if @suppliers.nil?

      @search = SupplierContact.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !letter.blank? && letter != "%"
          any_of do
            with(:last_name).starting_with(letter)
            with(:first_name).starting_with(letter)
          end
        end
        order_by :supplier_id, :asc
        order_by :last_name, :asc
        order_by :first_name, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @supplier_contacts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_contacts }
        format.js
      end
      puts "Path:"
      puts request.referrer
    end

    # GET /supplier_contacts/1
    # GET /supplier_contacts/1.json
    def show
      @breadcrumb = 'read'
      @supplier_contact = SupplierContact.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_contact }
      end
    end

    # GET /supplier_contacts/new
    # GET /supplier_contacts/new.json
    def new
      @breadcrumb = 'create'
      @supplier_contact = SupplierContact.new
      @suppliers = suppliers_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_contact }
      end
    end

    # GET /supplier_contacts/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_contact = SupplierContact.find(params[:id])
      @suppliers = suppliers_dropdown
    end

    # POST /supplier_contacts
    # POST /supplier_contacts.json
    def create
      @breadcrumb = 'create'
      @supplier_contact = SupplierContact.new(params[:supplier_contact])
      @supplier_contact.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier_contact.save
          format.html { redirect_to @supplier_contact, notice: crud_notice('created', @supplier_contact) }
          format.json { render json: @supplier_contact, status: :created, location: @supplier_contact }
        else
          @suppliers = suppliers_dropdown
          format.html { render action: "new" }
          format.json { render json: @supplier_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /supplier_contacts/1
    # PUT /supplier_contacts/1.json
    def update
      @breadcrumb = 'update'
      @supplier_contact = SupplierContact.find(params[:id])
      @supplier_contact.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier_contact.update_attributes(params[:supplier_contact])
          format.html { redirect_to @supplier_contact,
                        notice: (crud_notice('updated', @supplier_contact) + "#{undo_link(@supplier_contact)}").html_safe }
          format.json { head :no_content }
        else
          @suppliers = suppliers_dropdown
          format.html { render action: "edit" }
          format.json { render json: @supplier_contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /supplier_contacts/1
    # DELETE /supplier_contacts/1.json
    def destroy
      @supplier_contact = SupplierContact.find(params[:id])
      @supplier_contact.destroy

      respond_to do |format|
        format.html { redirect_to supplier_contacts_url,
                      notice: (crud_notice('destroyed', @supplier_contact) + "#{undo_link(@supplier_contact)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def suppliers_dropdown
      _suppliers = session[:organization] != '0' ? Supplier.where(organization_id: session[:organization].to_i).order(:supplier_code) : Supplier.order(:supplier_code)
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # supplier
      if params[:Supplier]
        session[:Supplier] = params[:Supplier]
      elsif session[:Supplier]
        params[:Supplier] = session[:Supplier]
      end
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end
  end
end
