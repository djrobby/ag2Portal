require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SupplierContactsController < ApplicationController
    # GET /supplier_contacts
    # GET /supplier_contacts.json
    def index
      @supplier_contacts = SupplierContact.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @supplier_contacts }
      end
    end
  
    # GET /supplier_contacts/1
    # GET /supplier_contacts/1.json
    def show
      @supplier_contact = SupplierContact.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier_contact }
      end
    end
  
    # GET /supplier_contacts/new
    # GET /supplier_contacts/new.json
    def new
      @supplier_contact = SupplierContact.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier_contact }
      end
    end
  
    # GET /supplier_contacts/1/edit
    def edit
      @supplier_contact = SupplierContact.find(params[:id])
    end
  
    # POST /supplier_contacts
    # POST /supplier_contacts.json
    def create
      @supplier_contact = SupplierContact.new(params[:supplier_contact])
  
      respond_to do |format|
        if @supplier_contact.save
          format.html { redirect_to @supplier_contact, notice: 'Supplier contact was successfully created.' }
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
      @supplier_contact = SupplierContact.find(params[:id])
  
      respond_to do |format|
        if @supplier_contact.update_attributes(params[:supplier_contact])
          format.html { redirect_to @supplier_contact, notice: 'Supplier contact was successfully updated.' }
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
        format.html { redirect_to supplier_contacts_url }
        format.json { head :no_content }
      end
    end
  end
end
