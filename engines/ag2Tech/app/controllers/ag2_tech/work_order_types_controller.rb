require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:wot_update_account_select_from_project]

    # Helper methods for sorting
    helper_method :sort_column

    # Update account select at view from project select
    def wot_update_account_select_from_project
      project = params[:project]
      tbl = params[:tbl]
      if project != '0'
        @project = Project.find(project)
        @accounts = @project.blank? ? project_charge_accounts_dropdown(nil) : @project.charge_accounts.expenditures
      else
        @accounts = project_charge_accounts_dropdown(nil)
      end
      # Setup JSON
      @json_data = { "account" => @accounts, "tbl" => tbl.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /work_order_types
    # GET /work_order_types.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @work_order_types = WorkOrderType.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @work_order_types = WorkOrderType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_types }
        format.js
      end
    end

    # GET /work_order_types/1
    # GET /work_order_types/1.json
    def show
      @breadcrumb = 'read'
      @work_order_type = WorkOrderType.find(params[:id])
      @worker_orders = @work_order_type.work_orders.paginate(:page => params[:page], :per_page => per_page).order(:order_no)
      @accounts = @work_order_type.work_order_type_accounts.paginate(:page => params[:page], :per_page => per_page).order(:id)
      @labors = @work_order_type.work_order_labors.paginate(:page => params[:page], :per_page => per_page).order(:id)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_type }
      end
    end

    # GET /work_order_types/new
    # GET /work_order_types/new.json
    def new
      @breadcrumb = 'create'
      @work_order_type = WorkOrderType.new
      @woareas = work_order_areas_dropdown
      @charge_accounts = charge_accounts_dropdown
      @projects = projects_dropdown
      @accounts = project_charge_accounts_dropdown(nil)

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_type }
      end
    end

    # GET /work_order_types/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order_type = WorkOrderType.find(params[:id])
      @woareas = work_order_areas_dropdown
      @charge_accounts = charge_accounts_dropdown
      @projects = projects_dropdown
      @accounts = project_charge_accounts_dropdown(nil)
    end

    # POST /work_order_types
    # POST /work_order_types.json
    def create
      @breadcrumb = 'create'
      @work_order_type = WorkOrderType.new(params[:work_order_type])
      @work_order_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_type.save
          format.html { redirect_to @work_order_type, notice: crud_notice('created', @work_order_type) }
          format.json { render json: @work_order_type, status: :created, location: @work_order_type }
        else
          @woareas = work_order_areas_dropdown
          @charge_accounts = charge_accounts_dropdown
          @projects = projects_dropdown
          @accounts = project_charge_accounts_dropdown(nil)
          format.html { render action: "new" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /work_order_types/1
    # PUT /work_order_types/1.json
    def update
      @breadcrumb = 'update'
      @work_order_type = WorkOrderType.find(params[:id])
      @work_order_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_type.update_attributes(params[:work_order_type])
          format.html { redirect_to @work_order_type,
                        notice: (crud_notice('updated', @work_order_type) + "#{undo_link(@work_order_type)}").html_safe }
          format.json { head :no_content }
        else
          @woareas = work_order_areas_dropdown
          @charge_accounts = charge_accounts_dropdown
          @projects = projects_dropdown
          @accounts = project_charge_accounts_dropdown(nil)
          format.html { render action: "edit" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /work_order_types/1
    # DELETE /work_order_types/1.json
    def destroy
      @work_order_type = WorkOrderType.find(params[:id])

      respond_to do |format|
        if @work_order_type.destroy
          format.html { redirect_to work_order_types_url,
                      notice: (crud_notice('destroyed', @work_order_type) + "#{undo_link(@work_order_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_order_types_url, alert: "#{@work_order_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def work_order_areas_dropdown
      session[:organization] != '0' ? WorkOrderArea.where(organization_id: session[:organization].to_i).order(:id) : WorkOrderArea.order(:id)
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.expenditures_no_project.where(organization_id: session[:organization].to_i) : ChargeAccount.expenditures_no_project
    end

    def project_charge_accounts_dropdown(_project)
      # Charge accounts by current project
      if _project.blank?
        charge_accounts_dropdown
      else
        ChargeAccount.expenditures.where('project_id = ?', _project)
      end
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def sort_column
      WorkOrderType.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    # Keeps filter state
    def manage_filter_state
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
