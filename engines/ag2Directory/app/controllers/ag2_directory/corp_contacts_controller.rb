require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class CorpContactsController < ApplicationController
    # GET /corp_contacts
    # GET /corp_contacts.json
    def index
      @corp_contacts = CorpContact.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @corp_contacts }
      end
    end
  
    # GET /corp_contacts/1
    # GET /corp_contacts/1.json
    def show
      @corp_contact = CorpContact.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @corp_contact }
      end
    end
  
    # GET /corp_contacts/new
    # GET /corp_contacts/new.json
    def new
      @corp_contact = CorpContact.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @corp_contact }
      end
    end
  
    # GET /corp_contacts/1/edit
    def edit
      @corp_contact = CorpContact.find(params[:id])
    end
  
    # POST /corp_contacts
    # POST /corp_contacts.json
    def create
      @corp_contact = CorpContact.new(params[:corp_contact])
  
      respond_to do |format|
        if @corp_contact.save
          format.html { redirect_to @corp_contact, notice: 'Corp contact was successfully created.' }
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
      @corp_contact = CorpContact.find(params[:id])
  
      respond_to do |format|
        if @corp_contact.update_attributes(params[:corp_contact])
          format.html { redirect_to @corp_contact, notice: 'Corp contact was successfully updated.' }
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
        format.html { redirect_to corp_contacts_url }
        format.json { head :no_content }
      end
    end
  end
end
