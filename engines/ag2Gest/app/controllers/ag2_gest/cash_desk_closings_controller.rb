require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CashDeskClosingsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:close_cash_form,
                                               :close_cash_report]
    helper_method :sort_column

    def close_cash_form
      # Right data to use:
      @close_cash = CashDeskClosing.find(params[:id])
      @cash_desk_closing_items = @close_cash.cash_desk_closing_items.order('cash_desk_closing_items.payment_method_id, cash_desk_closing_items.id')
      @instrument = @close_cash.cash_desk_closing_instruments.by_cu_value_id

      # This data is not neccesary & shouldn't be used
      # (don't touch because is used in close_cash_form.pdf.thinreports at 20171210...)
      # @close_cash_items_client = @close_cash.cash_desk_closing_items.joins(:client_payment).order('client_payments.payment_method_id, client_payments.bill_id')
      # @close_cash_items_supplier = @close_cash.cash_desk_closing_items.joins(:supplier_payment).order('supplier_payments.payment_method_id, supplier_payments.supplier_invoice_id')
      # @close_cash_items_movement = @close_cash.cash_desk_closing_items.joins(:cash_movement).order('cash_movements.payment_method_id, cash_movements.id')

      title = t("activerecord.models.cash_desk_closing.few")
        respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@close_cash.id}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

     # close_cash report
    def close_cash_report
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

      @search = CashDeskClosing.search do
        with :project_id, @project_ids unless @project_ids.blank?
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
            with(:created_at).greater_than(from)
            with :created_at, from
          end
        end
        if !to.blank?
          any_of do
            with(:created_at).less_than(to)
            with :created_at, to
          end
        end
        order_by sort_column, "desc"
          paginate :page => params[:page] || 1, :per_page => CashDeskClosing.count
        end

        # @close_cash_report = @search.results.sort_by{ |t| [t.company_id, t.project_id] }
        close_cash_ids = []
        @search.hits.each do |i|
          close_cash_ids << i.result.id
        end
        @close_cash_report = CashDeskClosing.with_these_ids(close_cash_ids).sort_by{ |t| [t.company_id, t.project_id] }

      if !@close_cash_report.blank?
        title = t("activerecord.models.cash_desk_closing.few")
        @from = formatted_date(@close_cash_report.first.created_at)
        @to = formatted_date(@close_cash_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data CashDeskClosing.to_csv(@close_cash_report),
                       filename: "#{title}_#{@from}-#{@to}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        end
      end
    end

    #
    # Default Methods
    #
    # GET /cash_desk_closings
    # GET /cash_desk_closings.json
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

      @search = CashDeskClosing.search do
        with :project_id, @project_ids unless @project_ids.blank?
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
            with(:created_at).greater_than(from)
            with :created_at, from
          end
        end
        if !to.blank?
          any_of do
            with(:created_at).less_than(to)
            with :created_at, to
          end
        end
        order_by sort_column, "desc"
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end

      @cash_desk_closings = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @cash_desk_closings }
        format.js
      end
    end

    # GET /cash_desk_closings/1
    # GET /cash_desk_closings/1.json
    def show
      @breadcrumb = 'read'
      @cash_desk_closing = CashDeskClosing.find(params[:id])
      @cash_desk_closing_items = @cash_desk_closing.cash_desk_closing_items.order('cash_desk_closing_items.payment_method_id').paginate(:page => params[:page], :per_page => per_page).order('id')
      @cash_desk_closing_instruments = @cash_desk_closing.cash_desk_closing_instruments.paginate(:page => params[:page], :per_page => per_page).by_cu_value_id

      @instruments_difference = @cash_desk_closing.instruments_difference
      if (@instruments_difference < 0 && @instruments_difference < -0.00)
        @instruments_difference = @instruments_difference * (-1)
      end

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @cash_desk_closing }
      end
    end

    private

    def sort_column
      CashDeskClosing.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
