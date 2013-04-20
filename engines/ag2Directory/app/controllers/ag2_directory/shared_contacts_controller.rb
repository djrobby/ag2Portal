require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class SharedContactsController < ApplicationController
    # Update hidden province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update hidden province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id }
    
      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /shared_contacts
    # GET /shared_contacts.json
    def index
      #@shared_contacts = SharedContact.all
      letter = params[:letter]
      
      @search = SharedContact.search do
        fulltext params[:search]
      end
      if letter.blank? || letter == "%"
        @shared_contacts = @search.results.sort_by{ |contact| [ contact.company, contact.last_name, contact.first_name ] }
      else
        @shared_contacts = SharedContact.order('company', 'last_name, first_name').where("last_name LIKE ?", "#{letter}%")
      end      
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @shared_contacts }
      end
    end
  
    # GET /shared_contacts/1
    # GET /shared_contacts/1.json
    def show
      @breadcrumb = 'read'
      @shared_contact = SharedContact.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @shared_contact }
      end
    end
  
    # GET /shared_contacts/new
    # GET /shared_contacts/new.json
    def new
      @breadcrumb = 'create'
      @shared_contact = SharedContact.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @shared_contact }
      end
    end
  
    # GET /shared_contacts/1/edit
    def edit
      @breadcrumb = 'update'
      @shared_contact = SharedContact.find(params[:id])
    end
  
    # POST /shared_contacts
    # POST /shared_contacts.json
    def create
      @breadcrumb = 'create'
      @shared_contact = SharedContact.new(params[:shared_contact])
  
      respond_to do |format|
        if @shared_contact.save
          format.html { redirect_to @shared_contact, notice: 'Shared contact was successfully created.' }
          format.json { render json: @shared_contact, status: :created, location: @shared_contact }
        else
          format.html { render action: "new" }
          format.json { render json: @shared_contact.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /shared_contacts/1
    # PUT /shared_contacts/1.json
    def update
      @breadcrumb = 'update'
      @shared_contact = SharedContact.find(params[:id])
  
      respond_to do |format|
        if @shared_contact.update_attributes(params[:shared_contact])
          format.html { redirect_to @shared_contact, notice: 'Shared contact was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @shared_contact.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /shared_contacts/1
    # DELETE /shared_contacts/1.json
    def destroy
      @shared_contact = SharedContact.find(params[:id])
      @shared_contact.destroy
  
      respond_to do |format|
        format.html { redirect_to shared_contacts_url }
        format.json { head :no_content }
      end
    end
  end
end
