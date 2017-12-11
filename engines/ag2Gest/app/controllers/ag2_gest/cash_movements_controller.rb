require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CashMovementsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # skip_load_and_authorize_resource :only => [:cl_update_textfields_from_organization,
    #                                            :update_province_textfield_from_town,
    #                                            :update_province_textfield_from_zipcode,
    #                                            :update_country_textfield_from_region,
    #                                            :update_region_textfield_from_province,
    #                                            :cl_generate_code,
    #                                            :et_validate_fiscal_id_textfield,
    #                                            :cl_validate_fiscal_id_textfield,
    #                                            :check_client_depent_subscribers]
    # Helpers
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /cash_movements
    # GET /cash_movements.json
    def index
      manage_filter_state

      project = params[:Project]
      office = params[:Office]
      company = params[:Company]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = current_projects if @projects.nil?
      @project_ids = current_projects_ids
      @offices = current_offices if @offices.nil?
      @companies = companies_dropdown if @companies.nil?

      @search = CashMovement.search do
        with :project_id, current_projects_ids unless current_projects_ids.blank?
        if !params[:search].blank?
          fulltext params[:search]
        end
        if !project.blank?
          with :project_id, project
        end
        if !office.blank?
          with :office_id, office
        end
        if !company.blank?
          with :company_id, company
        end
        if !from.blank?
          any_of do
            with(:movement_date).greater_than(from)
            with :movement_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:movement_date).less_than(to)
            with :movement_date, to
          end
        end
        order_by sort_column, "desc"
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @cash_movements = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @cash_movements }
        format.js
      end
    end

    # GET /cash_movements/1
    # GET /cash_movements/1.json
    def show
      @breadcrumb = 'read'
      @cash_movement = CashMovement.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @cash_movement }
      end
    end

    # GET /cash_movements/new
    # GET /cash_movements/new.json
    def new
      @breadcrumb = 'create'
      @cash_movement = CashMovement.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @cash_movement }
      end
    end

    # GET /cash_movements/1/edit
    def edit
      @breadcrumb = 'update'
      @cash_movement = CashMovement.find(params[:id])
    end

    # POST /cash_movements
    # POST /cash_movements.json
    def create
      @breadcrumb = 'create'
      @cash_movement = CashMovement.new(params[:cash_movement])
      @cash_movement.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement.save
          format.html { redirect_to @cash_movement, notice: crud_notice('created', @cash_movement) }
          format.json { render json: @cash_movement, status: :created, location: @cash_movement }
        else
          format.html { render action: "new" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /cash_movements/1
    # PUT /cash_movements/1.json
    def update
      @breadcrumb = 'update'
      @cash_movement = CashMovement.find(params[:id])
      @cash_movement.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement.update_attributes(params[:cash_movement])
          format.html { redirect_to @cash_movement,
                        notice: (crud_notice('updated', @cash_movement) + "#{undo_link(@cash_movement)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /cash_movements/1
    # DELETE /cash_movements/1.json
    def destroy
      @cash_movement = CashMovement.find(params[:id])

      respond_to do |format|
        if @cash_movement.destroy
          format.html { redirect_to cash_movements_url,
                      notice: (crud_notice('destroyed', @cash_movement) + "#{undo_link(@cash_movement)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to cash_movements_url, alert: "#{@cash_movement.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      CashMovement.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def companies_dropdown
      if session[:company] != '0'
        [Company.find(session[:company])]
      elsif session[:organization] != '0'
        Company.where(organization_id: session[:organization]).order("name")
      else
        Company.order("name")
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

      # Project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end

      # Office
      if params[:Office]
        session[:Office] = params[:Office]
      elsif session[:Office]
        params[:Office] = session[:Office]
      end

      # Company
      if params[:Company]
        session[:Company] = params[:Company]
      elsif session[:Company]
        params[:Company] = session[:Company]
      end

      # From
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end

      # To
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end

      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end
  end
end
