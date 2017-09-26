require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:dc_remove_filters,
                                               :dc_restore_filters,
                                               :dc_generate_no]
    # Helper methods for
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
      type = params[:Type]
      operation = params[:Operation]
      biller = params[:Biller]
      # OCO
      init_oco if !session[:organization]

      @client = " "
      @project = !project.blank? ? Project.find(project).full_name : " "
      @biller = !biller.blank? ? Company.find(biller).full_name : " "
      @status = invoice_statuses_dropdown if @status.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @sale_offers = sale_offers_dropdown if @sale_offers.nil?

      @debt_claims = DebtClaim.paginate(:page => params[:page], :per_page => per_page)

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
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
      # type
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end
      # operation
      if params[:Operation]
        session[:Operation] = params[:Operation]
      elsif session[:Operation]
        params[:Operation] = session[:Operation]
      end
      # biller
      if params[:Biller]
        session[:Biller] = params[:Biller]
      elsif session[:Biller]
        params[:Biller] = session[:Biller]
      end
    end

    def dc_remove_filters
      params[:search] = ""
      params[:No] = ""
      params[:Project] = ""
      params[:Client] = ""
      params[:Status] = ""
      params[:Type] = ""
      params[:Operation] = ""
      params[:Biller] = ""
      return " "
    end

    def dc_restore_filters
      params[:search] = session[:search]
      params[:No] = session[:No]
      params[:Project] = session[:Project]
      params[:Client] = session[:Client]
      params[:Status] = session[:Status]
      params[:Type] = session[:Type]
      params[:Operation] = session[:Operation]
      params[:Biller] = session[:Biller]
    end
  end
end
