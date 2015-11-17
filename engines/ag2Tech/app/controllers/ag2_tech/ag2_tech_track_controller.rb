require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Ag2TechTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:project_report,
                                               :budget_report,
                                               :work_report,
                                               :te_track_project_has_changed,
                                               :te_track_family_has_changed]

    # Update work order, charge account select fields at view from project select
    def te_track_project_has_changed
      project = params[:order]
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? work_orders_dropdown : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? charge_accounts_dropdown : charge_accounts_dropdown_edit(@project.id)
      else
        @work_order = work_orders_dropdown
        @charge_account = charge_accounts_dropdown
      end
      @json_data = { "work_order" => @work_order, "charge_account" => @charge_account }
      render json: @json_data
    end

    # Projects report
    def project_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      order = params[:order]
      account = params[:account]

      # Dates are mandatory
      if @from.blank? || @to.blank? 
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)
      
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.project.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Budgets report
    def budget_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      account = params[:account]
      period = params[:period]

      # Dates are mandatory
      if @from.blank? || @to.blank? 
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)
      
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.budget.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Work orders report
    def work_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      order = params[:order]
      account = params[:account]

      # Dates are mandatory
      if @from.blank? || @to.blank? 
        return
      end

      # Search necessary data
      #@worker = Worker.find(worker)
      
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      # Setup filename
      title = t("activerecord.models.work_order.few") + "_#{from}_#{to}.pdf"      
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "#{title}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    #
    # Default Methods
    #
    def index
      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end
      
      @projects = @organization.blank? ? projects_dropdown : @organization.projects.order(:project_code)
      @work_orders = @organization.blank? ? work_orders_dropdown : @organization.work_orders.order(:order_no)
      @charge_accounts = @organization.blank? ? charge_accounts_dropdown : @organization.charge_accounts.order(:account_code)
      @periods = @organization.blank? ? periods_dropdown : @organization.budget_periods.order(:period_code)
    end
    
    private
    
    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.project.few")
      _array = _array << t("activerecord.models.budget.few")
      _array = _array << t("activerecord.models.work_order.few")
      _array
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

    def work_orders_dropdown
      _orders = session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def charge_accounts_dropdown
      _accounts = session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      _accounts = ChargeAccount.where('project_id = ? OR project_id IS NULL', _project).order(:account_code)
    end

    def periods_dropdown
      session[:organization] != '0' ? BudgetPeriod.where(organization_id: session[:organization].to_i).order(:period_code) : BudgetPeriod.order(:period_code)
    end
  end
end
