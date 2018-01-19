require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Ag2TechTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:project_report,
                                               :budget_report,
                                               :work_report,
                                               :charge_account_track_report,
                                               :te_track_project_has_changed,
                                               :te_track_family_has_changed]

    # Update work order, charge account select fields at view from project select
    def te_track_project_has_changed
      project = params[:order]
      projects = projects_dropdown
      if project != '0'
        @project = Project.find(project)
        @work_order = @project.blank? ? projects_work_orders(projects) : @project.work_orders.order(:order_no)
        @charge_account = @project.blank? ? projects_charge_accounts(projects) : charge_accounts_dropdown_edit(@project)
      else
        @work_order = projects_work_orders(projects)
        @charge_account = projects_charge_accounts(projects)
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

     from = Time.parse(@from).strftime("%Y-%m-%d")
     to = Time.parse(@to).strftime("%Y-%m-%d")

      if project.blank?
        @project_report = Project.where("created_at >= ? AND created_at <= ?",from,to).order(:company_id)
      else
        @project_report = Project.where("id = ? AND created_at >= ? AND created_at <= ?",project,from,to).order(:company_id)
      end

      title = t("activerecord.models.project.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@project_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Project.to_csv(@project_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    # Charge Accounts report
    def charge_account_track_report
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      order = params[:order]
      account = params[:account]

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      from = Date.today.to_s

      @charge_account_report = ChargeAccount.where("project_id in (?) ",project).order(:charge_group_id, :account_code)

      title = t("activerecord.models.charge_account.few") + "_#{from}.pdf"

      respond_to do |format|
        # Render PDF
        if !@charge_account_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data ChargeAccount.to_csv(@charge_account_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
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

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

     from = Time.parse(@from).strftime("%Y-%m-%d")
     to = Time.parse(@to).strftime("%Y-%m-%d")

      @budget_report = Budget.where("project_id in (?) AND created_at >= ? AND created_at <= ?",project,from,to).order(:budget_no)

      title = t("activerecord.models.budget.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@budget_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Budget.to_csv(@budget_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
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

      if project.blank?
        init_oco if !session[:organization]
        # Initialize select_tags
        @projects = projects_dropdown if @projects.nil?
        # Arrays for search
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.to_a
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

     from = Time.parse(@from).strftime("%Y-%m-%d")
     to = Time.parse(@to).strftime("%Y-%m-%d")

      if !project.blank? and !order.blank?
        @work_report = WorkOrder.where("project_id in (?) AND id = ? AND created_at >= ? AND created_at <= ?",project,order,from,to).order(:project_id)
      elsif !project.blank? and !order.blank?
        @work_report = WorkOrder.where("project_id in (?) AND id = ? AND created_at >= ? AND created_at <= ?",order,from,to).order(:project_id)
      elsif !project.blank? and order.blank?
        @work_report = WorkOrder.where("project_id in (?) AND created_at >= ? AND created_at <= ?",project,from,to).order(:project_id)
      elsif !project.blank? and order.blank?
        @work_report = WorkOrder.where("project_id in (?) AND created_at >= ? AND created_at <= ?",project,from,to).order(:project_id)
      end

      title = t("activerecord.models.work_order.few") + "_#{from}_#{to}.pdf"

      respond_to do |format|
        # Render PDF
        if !@work_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data WorkOrder.to_csv(@work_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_tech_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    #
    # Default Methods
    #
    def index
      project = params[:Project]
      order = params[:Order]
      account = params[:Account]

      @reports = reports_array
      @organization = nil
      if session[:organization] != '0'
        @organization = Organization.find(session[:organization].to_i)
      end

      @project = !project.blank? ? Project.find(project).full_name : " "
      @work_order = !order.blank? ? WorkOrder.find(order).full_name : " "
      @charge_account = !account.blank? ? ChargeAccount.find(account).full_name : " "

      @periods = periods_dropdown
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.project.few")
      _array = _array << t("activerecord.models.budget.few")
      _array = _array << t("activerecord.models.work_order.few")
      _array = _array << t("activerecord.models.charge_account.few")
      _array
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
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
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    # Work orders belonging to projects
    def projects_work_orders(_projects)
      _array = []
      _ret = nil

      # Adding work orders belonging to current projects
      _ret = WorkOrder.where(project_id: _projects)
      ret_array(_array, _ret)
      # _projects.each do |i|
      #   _ret = WorkOrder.where(project_id: i.id)
      #   ret_array(_array, _ret)
      # end

      # Returning founded work orders
      _ret = WorkOrder.where(id: _array).order(:order_no)
    end

    def charge_accounts_dropdown
      session[:organization] != '0' ? ChargeAccount.where(organization_id: session[:organization].to_i).order(:account_code) : ChargeAccount.order(:account_code)
    end

    def charge_accounts_dropdown_edit(_project)
      ChargeAccount.where('project_id = ? OR (project_id IS NULL AND organization_id = ?)', _project.id, _project.organization_id).order(:account_code)
    end

    # Charge accounts belonging to projects
    def projects_charge_accounts(_projects)
      _array = []
      _ret = nil

      # Adding charge accounts belonging to current projects
      _ret = ChargeAccount.where(project_id: _projects)
      ret_array(_array, _ret)
      # _projects.each do |i|
      #   _ret = ChargeAccount.where(project_id: i.id)
      #   ret_array(_array, _ret)
      # end

      # Adding global charge accounts
      _ret = ChargeAccount.where('project_id IS NULL')
      ret_array(_array, _ret)

      # Returning founded charge accounts
      _ret = ChargeAccount.where(id: _array).order(:account_code)
    end

    def periods_dropdown
      session[:organization] != '0' ? BudgetPeriod.where(organization_id: session[:organization].to_i).order(:period_code) : BudgetPeriod.order(:period_code)
    end

    def ret_array(_array, _ret)
      _ret.each do |_r|
        _array = _array << _r.id unless _array.include? _r.id
      end
    end
  end
end
