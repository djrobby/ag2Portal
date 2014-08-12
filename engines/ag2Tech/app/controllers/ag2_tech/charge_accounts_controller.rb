require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeAccountsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:cc_generate_code]

    # Update account code at view (generate_code_btn)
    def cc_generate_code
      header = params[:header]
      code = ''

      # Builds code, if possible
      if header == '$'
        code = '$err'
      else
        header = header.to_s if header.is_a? Fixnum
        header = header.rjust(4, '0')
        last_code = ChargeAccount.where("account_code LIKE ?", "#{header}%").order(:account_code).maximum(:account_code)
        if last_code.nil?
          code = header + '0000001'
        else
          last_code = last_code[4..10].to_i + 1
          code = header + last_code.to_s.rjust(7, '0')
        end
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /charge_accounts
    # GET /charge_accounts.json
    def index
      manage_filter_state
      project = params[:Project]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
  
      @search = ChargeAccount.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !project.blank?
          with :project_id, project
        end
        order_by :account_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @charge_accounts = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @charge_accounts }
      end
    end
  
    # GET /charge_accounts/1
    # GET /charge_accounts/1.json
    def show
      @breadcrumb = 'read'
      @charge_account = ChargeAccount.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/new
    # GET /charge_accounts/new.json
    def new
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new
      @projects = projects_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/1/edit
    def edit
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
      @projects = projects_dropdown_edit(@charge_account.project)
    end
  
    # POST /charge_accounts
    # POST /charge_accounts.json
    def create
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new(params[:charge_account])
      @charge_account.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.save
          format.html { redirect_to @charge_account, notice: crud_notice('created', @charge_account) }
          format.json { render json: @charge_account, status: :created, location: @charge_account }
        else
          @projects = projects_dropdown
          format.html { render action: "new" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /charge_accounts/1
    # PUT /charge_accounts/1.json
    def update
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
      @charge_account.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.update_attributes(params[:charge_account])
          format.html { redirect_to @charge_account,
                        notice: (crud_notice('updated', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          @projects = projects_dropdown_edit(@charge_account.project)
          format.html { render action: "edit" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /charge_accounts/1
    # DELETE /charge_accounts/1.json
    def destroy
      @charge_account = ChargeAccount.find(params[:id])

      respond_to do |format|
        if @charge_account.destroy
          format.html { redirect_to charge_accounts_url,
                      notice: (crud_notice('destroyed', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to charge_accounts_url, alert: "#{@charge_account.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end
    
    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
    end
  end
end
