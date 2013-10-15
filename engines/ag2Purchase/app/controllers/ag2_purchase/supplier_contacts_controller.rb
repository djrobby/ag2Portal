require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierContactsController < ApplicationController
    # GET /supplier_contacts
    # GET /supplier_contacts.json
    def index
      letter = params[:letter]

      @search = SupplierContact.search do
        fulltext params[:search]
        order_by :supplier_id, :asc
        order_by :last_name, :asc
        order_by :first_name, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      if letter.blank? || letter == "%"
        @supplier_contacts = @search.results
      else
        @supplier_contacts = SupplierContact.where("last_name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('supplier_id', 'last_name, first_name')
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_contacts }
      end
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
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_contact }
      end
    end
  
    # GET /supplier_contacts/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier_contact = SupplierContact.find(params[:id])
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
  end
end
