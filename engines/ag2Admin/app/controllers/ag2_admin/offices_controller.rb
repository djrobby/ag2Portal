require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class OfficesController < ApplicationController
#    def internal
#      @companies = Company.all
#    end

    # Update office code at view from zip code select (button from edit or new)
    def update_code_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @json_data = { "zipcode" => @zipcode.zipcode }
    
      respond_to do |format|
        format.html # update_code_textfield_from_zipcode.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end
    
    # Update province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "zipcode" => @zipcode.zipcode }
    
      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # GET /offices
    # GET /offices.json
    def index
#      internal 
      @offices = Office.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offices }
      end
    end

    # GET /offices/1
    # GET /offices/1.json
    def show
      @office = Office.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @office }
      end
    end

    # GET /offices/new
    # GET /offices/new.json
    def new
#      internal
      @office = Office.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @office }
      end
    end

    # GET /offices/1/edit
    def edit
#      internal
      @office = Office.find(params[:id])
    end

    # POST /offices
    # POST /offices.json
    def create
#      internal
      @office = Office.new(params[:office])

      respond_to do |format|
        if @office.save
          format.html { redirect_to @office, notice: 'Office was successfully created.' }
          format.json { render json: @office, status: :created, location: @office }
        else
          format.html { render action: "new" }
          format.json { render json: @office.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /offices/1
    # PUT /offices/1.json
    def update
#      internal
      @office = Office.find(params[:id])

      respond_to do |format|
        if @office.update_attributes(params[:office])
          format.html { redirect_to @office, notice: 'Office was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @office.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /offices/1
    # DELETE /offices/1.json
    def destroy
      @office = Office.find(params[:id])
      @office.destroy

      respond_to do |format|
        format.html { redirect_to offices_url }
        format.json { head :no_content }
      end
    end
  end
end
