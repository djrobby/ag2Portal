require_dependency "ag2_human/application_controller"

module Ag2Human
  class WorkersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_textfields_to_uppercase,
                                               :update_email_textfield_from_user,
                                               :update_company_textfield_from_office,
                                               :update_code_textfield_from_name,
                                               :update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :wk_update_attachment,
                                               :validate_fiscal_id_textfield]
    # Public attachment for drag&drop
    $attachment = nil
  
    # Update attached file from drag&drop
    def wk_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment.avatar = params[:file]
      $attachment.id = 1
      $attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end

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

    # Update offices from company select
    def update_offices_select_from_company
      if params[:id] == '0'
        @offices = Office.order('name')
      else
        company = Company.find(params[:id])
        if !company.nil?
          @offices = company.offices.order('name')
        else
          @offices = Office.order('name')
        end
      end

      respond_to do |format|
        format.html # update_offices_select_from_company.html.erb does not exist! JSON only
        format.json { render json: @offices }
      end
    end

    # Validate fiscal id
    def validate_fiscal_id_textfield
      fiscal_id = params[:id]
      dc = ''
      f_id = 'OK'
      f_name = ''

      if fiscal_id == '0'
        f_id = '$err'
      else
        dc = fiscal_id_dc(fiscal_id)
        if dc == '$par' || dc == '$err'
          f_id = '$err'
        else
          if dc == '$uni'
            f_id = '??'
          end
          f_name = fiscal_id_description(fiscal_id[0])
          if f_name == '$err'
            f_name = I18n.t("ag2_admin.entities.fiscal_name")
          end
          if is_numeric?(fiscal_id[0]) && fiscal_id.to_s.length == 8
            fiscal_id = fiscal_id.to_s + dc
          end
        end
      end

      @json_data = { "f_id" => f_id, "fiscal_name" => f_name, "fiscal_id" => fiscal_id }
      render json: @json_data
    end

    #
    # Advanced searchers
    # DO NOT use strings as queries to avoid SQL injection exploits!
    #
    # Search workers
    def search
=begin
company = params[:Company]
office = params[:Office]
letter = params[:letter]

@search = Worker.search do
fulltext params[:search]
if !company.blank?
with :company_id, company
end
if !office.blank?
with :office_id, office
end
end
if letter.blank? || letter == "%"
@workers = @search.results.sort_by{ |worker| worker.worker_code }
else
@workers = Worker.order('worker_code').where("last_name LIKE ?", "#{letter}%")
end

respond_to do |format|
format.html # search.html.erb
format.json { render json: @workers }
end
=end
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
    end

    #
    # Default Methods
    #
    # GET /workers
    # GET /workers.json
    def index
      manage_filter_state
      company = params[:Company]
      office = params[:Office]
      letter = params[:letter]

      if !company.blank? && !office.blank?
        #@workers = Worker.where(id: WorkerItem.where(company_id: company, office_id: office)).paginate(:page => params[:page], :per_page => per_page).order('worker_code, id')
        @workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: company, office_id: office }).paginate(:page => params[:page], :per_page => per_page).order('worker_code, id')
      elsif !company.blank? && office.blank?
        @workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: company }).paginate(:page => params[:page], :per_page => per_page).order('worker_code, id')
      elsif company.blank? && !office.blank?
        @workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { office_id: office }).paginate(:page => params[:page], :per_page => per_page).order('worker_code, id')
      else
        @search = Worker.search do
          fulltext params[:search]
          if !letter.blank? && letter != "%"
            with(:last_name).starting_with(letter)
          end
          order_by :worker_code, :asc
          order_by :id, :asc
          paginate :page => params[:page] || 1, :per_page => per_page
        end
        @workers = @search.results
=begin
        if letter.blank? || letter == "%"
          @workers = @search.results
        else
          # @workers = Worker.order('worker_code').where("last_name LIKE ?", "#{letter}%")
          @workers = Worker.where("last_name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('worker_code, id')
        end
=end
      end

      # Initialize select_tags
      @companies = Company.order('name') if @companies.nil?
      @offices = Office.order('name') if @offices.nil?

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
      @worker_items = @worker.worker_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      #@worker_salaries = @worker.worker_salaries.paginate(:page => params[:page], :per_page => per_page).order('year desc')

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
      $attachment = Attachment.new
      destroy_attachment

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @worker }
      end
    end

    # GET /workers/1/edit
    def edit
      @breadcrumb = 'update'
      @worker = Worker.find(params[:id])
      $attachment = Attachment.new
      destroy_attachment
    end

    # POST /workers
    # POST /workers.json
    def create
      @breadcrumb = 'create'
      @worker = Worker.new(params[:worker])
      @worker.created_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if @worker.avatar.blank? && !$attachment.avatar.blank?
        @worker.avatar = $attachment.avatar
      end

      respond_to do |format|
        if @worker.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @worker, notice: crud_notice('created', @worker) }
          format.json { render json: @worker, status: :created, location: @worker }
        else
          $attachment.destroy
          $attachment = Attachment.new
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
      @worker.updated_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if !$attachment.avatar.blank? && $attachment.updated_at > @worker.updated_at
        @worker.avatar = $attachment.avatar
      end

      respond_to do |format|
        if @worker.update_attributes(params[:worker])
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @worker,
                        notice: (crud_notice('updated', @worker) + "#{undo_link(@worker)}").html_safe }
          format.json { head :no_content }
        else
          $attachment.destroy
          $attachment = Attachment.new
          format.html { render action: "edit" }
          format.json { render json: @worker.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /workers/1
    # DELETE /workers/1.json
    def destroy
      @worker = Worker.find(params[:id])

      respond_to do |format|
        if @worker.destroy
          format.html { redirect_to workers_url,
                      notice: (crud_notice('destroyed', @worker) + "#{undo_link(@worker)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to workers_url, alert: "#{@worker.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @worker.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # company
      if params[:Company]
        session[:Company] = params[:Company]
      elsif session[:Company]
        params[:Company] = session[:Company]
      end
      # office
      if params[:Office]
        session[:Office] = params[:Office]
      elsif session[:Office]
        params[:Office] = session[:Office]
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
