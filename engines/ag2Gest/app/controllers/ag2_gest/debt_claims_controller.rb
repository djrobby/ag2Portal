require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:dc_remove_filters,
                                               :dc_restore_filters,
                                               :dc_generate_no]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit
    # => returns client code & full name
    helper_method :client_name
    # => index filters
    helper_method :dc_remove_filters, :dc_restore_filters

    # Update claim number at view (generate_code_btn)
    def dc_generate_no
      project = params[:project]

      # Builds no, if possible
      code = project == '$' ? '$err' : dc_next_no(project)
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /debt_claims
    # GET /debt_claims.json
    def index
      manage_filter_state
      no = params[:No]
      project = params[:Project]
      client = params[:Client]
      status = params[:Status]
      phase = params[:Phase]
      # OCO
      init_oco if !session[:organization]

      # Initialize select_tags
      @client = !client.blank? ? Client.find(client).to_label : " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @status = debt_claim_statuses_dropdown if @status.nil?
      @phase = debt_claim_phases_dropdown if @phase.nil?

      # Arrays for search
      @projects = projects_dropdown if @projects.nil?
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      if !client.blank? && !status.blank?
        items = DebtClaimItem.belongs_to_client_and_has_status(client, status)
      elsif !client.blank? && status.blank?
        items = DebtClaimItem.belongs_to_client(client)
      elsif client.blank? && !status.blank?
        items = DebtClaimItem.has_status(status)
      else
        items = DebtClaimItem.grouped_by_debt_claim
      end
      current_items = items.blank? ? [0] : current_items_for_index(items)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = DebtClaim.search do
        with :id, current_items
        with :project_id, current_projects
        fulltext params[:search]
        if !no.blank?
          if no.class == Array
            with :claim_no, no
          else
            with(:claim_no).starting_with(no)
          end
        end
        if !project.blank?
          with :project_id, project
        end
        if !phase.blank?
          with :debt_claim_phase_id, phase
        end
        data_accessor_for(DebtClaim).include = [:debt_claim_phase, :project, {debt_claim_items: :debt_claim_status}, {debt_claim_items: {bill: :client}}]
        order_by :sort_no, :desc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @debt_claims = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claims }
        format.js
      end
    end

    # GET /debt_claims/1
    # GET /debt_claims/1.json
    def show
      @breadcrumb = 'read'
      @debt_claim = DebtClaim.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/new
    # GET /debt_claims/new.json
    def new
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/1/edit
    def edit
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
    end

    # POST /debt_claims
    # POST /debt_claims.json
    def create
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new(params[:debt_claim])
      @debt_claim.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.save
          format.html { redirect_to @debt_claim, notice: crud_notice('created', @debt_claim) }
          format.json { render json: @debt_claim, status: :created, location: @debt_claim }
        else
          format.html { render action: "new" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /debt_claims/1
    # PUT /debt_claims/1.json
    def update
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
      @debt_claim.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.update_attributes(params[:debt_claim])
          format.html { redirect_to @debt_claim,
                        notice: (crud_notice('updated', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /debt_claims/1
    # DELETE /debt_claims/1.json
    def destroy
      @debt_claim = DebtClaim.find(params[:id])

      respond_to do |format|
        if @debt_claim.destroy
          format.html { redirect_to debt_claims_url,
                      notice: (crud_notice('destroyed', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to debt_claims_url, alert: "#{@debt_claim.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Claim is closed
    def cannot_edit(_claim)
      !session[:is_administrator] && _claim.debt_claim_phase_id == DebtClaimPhase::CLOSED
    end

    def client_name(_bill)
      _name = _bill.client.full_name_or_company_and_code rescue nil
      _name.blank? ? '' : _name[0,40]
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def current_items_for_index(_items)
      _items.pluck(:debt_claim_id)
    end

    def inverse_no_search(no)
      _numbers = []
      # Add numbers found
      SaleOffer.where('offer_no LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.offer_no
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def projects_dropdown
      _array = []
      _projects = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
        else
          _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
        else
          _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
        end
      end

      # Returning founded projects
      ret_array(_array, _projects, 'id')
      _projects = Project.where(id: _array).by_code
    end

    def projects_dropdown_edit(_project)
      _projects = projects_dropdown
      if _projects.blank?
        _projects = Project.where(id: _project)
      end
      _projects
    end

    def debt_claim_phases_dropdown
      DebtClaimPhase.all
    end

    def debt_claim_statuses_dropdown
      DebtClaimStatus.all
    end

    # Returns _array from _ret table/model filled with _id attribute
    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
      end
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # no
      if params[:No]
        session[:No] = params[:No]
      elsif session[:No]
        params[:No] = session[:No]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # client
      if params[:Client]
        session[:Client] = params[:Client]
      elsif session[:Client]
        params[:Client] = session[:Client]
      end
      # phase
      if params[:Phase]
        session[:Phase] = params[:Phase]
      elsif session[:Phase]
        params[:Phase] = session[:Phase]
      end
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
    end

    def dc_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Project] = ""
      params[:Client] = ""
      params[:Phase] = ""
      params[:Status] = ""
      return " "
    end

    def dc_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Client] = session[:Client]
      params[:Phase] = session[:Phase]
      params[:Status] = session[:Status]
    end
  end
end
