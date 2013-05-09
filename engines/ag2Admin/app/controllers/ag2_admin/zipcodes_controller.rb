require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ZipcodesController < ApplicationController
    # Update hidden province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)
  
      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end
    
    # GET /zipcodes
    # GET /zipcodes.json
    def index
      @zipcodes = Zipcode.order('zipcode').all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @zipcodes }
      end
    end
  
    # GET /zipcodes/1
    # GET /zipcodes/1.json
    def show
      @breadcrumb = 'read'
      @zipcode = Zipcode.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @zipcode }
      end
    end
  
    # GET /zipcodes/new
    # GET /zipcodes/new.json
    def new
      @breadcrumb = 'create'
      @zipcode = Zipcode.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @zipcode }
      end
    end
  
    # GET /zipcodes/1/edit
    def edit
      @breadcrumb = 'update'
      @zipcode = Zipcode.find(params[:id])
    end
  
    # POST /zipcodes
    # POST /zipcodes.json
    def create
      @breadcrumb = 'create'
      @zipcode = Zipcode.new(params[:zipcode])
      @zipcode.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @zipcode.save
          format.html { redirect_to @zipcode, notice: I18n.t('activerecord.successful.messages.created', :model => @zipcode.class.model_name.human) }
          format.json { render json: @zipcode, status: :created, location: @zipcode }
        else
          format.html { render action: "new" }
          format.json { render json: @zipcode.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /zipcodes/1
    # PUT /zipcodes/1.json
    def update
      @breadcrumb = 'update'
      @zipcode = Zipcode.find(params[:id])
      @zipcode.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @zipcode.update_attributes(params[:zipcode])
          format.html { redirect_to @zipcode, notice: I18n.t('activerecord.successful.messages.updated', :model => @zipcode.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @zipcode.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /zipcodes/1
    # DELETE /zipcodes/1.json
    def destroy
      @zipcode = Zipcode.find(params[:id])
      @zipcode.destroy
  
      respond_to do |format|
        format.html { redirect_to zipcodes_url }
        format.json { head :no_content }
      end
    end
  end
end
