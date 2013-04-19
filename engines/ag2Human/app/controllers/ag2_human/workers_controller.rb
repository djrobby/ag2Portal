require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkersController < ApplicationController
    # Update worker data to upper case at view (to_uppercase_btn)
    def update_textfields_to_uppercase
      lastname = params[:last].upcase
      firstname = params[:first].upcase
      workercode = params[:code].upcase
      fiscalid = params[:fiscal].upcase

      if workercode == '$ERR'
        workercode = '$err'
      end
      @json_data = { "last" => lastname, "first" => firstname, "code" => workercode, "fiscal" => fiscalid }

      respond_to do |format|
        format.html # update_textfields_to_uppercase.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update email text field at view from user select
    def update_email_textfield_from_user
      @user = User.find(params[:id])

      respond_to do |format|
        format.html # update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @user }
      end
    end

    # Update company text field at view from office select
    def update_company_textfield_from_office
      @office = Office.find(params[:id])
      @company = Company.find(@office.company)

      respond_to do |format|
        format.html # update_company_textfield_from_office.html.erb does not exist! JSON only
        format.json { render json: @company }
      end
    end

    # Update worker code at view from last_name and first_name (generate_code_btn)
    def update_code_textfield_from_name
      fullname = params[:id]
      lastname = fullname.split("$").first
      firstname = fullname.split("$").last
      lastname1 = lastname.split(" ").first
      lastname2 = lastname.split(" ").last
      code = ''

      # Builds code, if possible
      if !lastname1.nil? && lastname1.length > 1
      code += lastname1[0, 2]
      end
      if !lastname2.nil? && lastname2.length > 1
      code += lastname2[0, 2]
      end
      if !firstname.nil? && firstname.length > 0
      code += firstname[0, 1]
      end

      if code == ''
        code = 'LLNNF'
      else
        if code.length < 5
          code = code.ljust(5, '0')
        end
      end

      code.upcase!
      if code == 'LLNNF'
        code = '$err'
      end
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

    #
    # Advanced search workers
    # DO NOT use strings as queries to avoid SQL injection exploits!
    #
    def search
      company = params[:Company]
      office = params[:Office]
      
      has_company = !company.nil? && company != ""
      has_office = !office.nil? && office != ""

      @search = Worker.search do
        fulltext params[:search]
        if has_company
          with :company_id, company
        end
        if has_office
          with :office_id, office
        end
      end
      @workers = @search.results.sort_by{ |worker| worker.worker_code }
      
=begin
      case
      when !has_company && !has_office
        @workers = Worker.order('worker_code').all
      when has_company && !has_office
        @workers = Worker.order('worker_code').where("company_id = ?", company)
      when !has_company && has_office
        @workers = Worker.order('worker_code').where("office_id = ?", office)
      when has_company && has_office
        @workers = Worker.order('worker_code').where("company_id = ? AND office_id = ?", company, office)
      end
=end
      
      respond_to do |format|
        format.html # search.html.erb
        format.json { render json: @workers }
      end
    end

    #
    # Default Methods
    #
    # GET /workers
    # GET /workers.json
    def index
      #@workers = Worker.all
      @search = Worker.search do
        fulltext params[:search]
      end
      @workers = @search.results.sort_by{ |worker| worker.worker_code }

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @workers }
      end
    end

    # GET /workers/1
    # GET /workers/1.json
    def show
      @breadcrumb = 'read'
      @worker = Worker.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @worker }
      end
    end

    # GET /workers/new
    # GET /workers/new.json
    def new
      @breadcrumb = 'create'
      @worker = Worker.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker }
      end
    end

    # GET /workers/1/edit
    def edit
      @breadcrumb = 'update'
      @worker = Worker.find(params[:id])
    end

    # POST /workers
    # POST /workers.json
    def create
      @breadcrumb = 'create'
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
      @breadcrumb = 'update'
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
