require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkersController < ApplicationController
    # Update company text field at view from office select
    def update_company_textfield_from_office
      @office = Office.find(params[:id])
      @company = Company.find(@office.company)

      respond_to do |format|
        format.html # update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end

    # Update worker code at view from last_name and first_name (button from edit or new)
    def update_code_textfield_from_name
      fullname = params[:id]
      code = 'LLNNF'
      @json_data = { "code" => code }
    
      respond_to do |format|
        format.html # update_code_textfield_from_name.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end
    
    # Update province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield_from_town.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id }
    
      respond_to do |format|
        format.html # update_province_textfield_from_zipcode.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # GET /workers
    # GET /workers.json
    def index
      @workers = Worker.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @workers }
      end
    end
  
    # GET /workers/1
    # GET /workers/1.json
    def show
      @worker = Worker.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker }
      end
    end
  
    # GET /workers/new
    # GET /workers/new.json
    def new
      @worker = Worker.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker }
      end
    end
  
    # GET /workers/1/edit
    def edit
      @worker = Worker.find(params[:id])
    end
  
    # POST /workers
    # POST /workers.json
    def create
      @worker = Worker.new(params[:worker])
  
      respond_to do |format|
        if @worker.save
          format.html { redirect_to @worker, notice: 'Worker was successfully created.' }
          format.json { render json: @worker, status: :created, location: @worker }
        else
          format.html { render action: "new" }
          format.json { render json: @worker.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /workers/1
    # PUT /workers/1.json
    def update
      @worker = Worker.find(params[:id])
  
      respond_to do |format|
        if @worker.update_attributes(params[:worker])
          format.html { redirect_to @worker, notice: 'Worker was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @worker.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /workers/1
    # DELETE /workers/1.json
    def destroy
      @worker = Worker.find(params[:id])
      @worker.destroy
  
      respond_to do |format|
        format.html { redirect_to workers_url }
        format.json { head :no_content }
      end
    end
  end
end
