require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SaleOffersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ci_generate_no,
                                               :ci_update_selects_from_organization,
                                               :ci_update_offer_select_from_client,
                                               :ci_update_selects_from_offer,
                                               :ci_update_selects_from_project,
                                               :ci_format_number,
                                               :ci_format_number_4,
                                               :ci_item_totals,
                                               :ci_update_description_prices_from_product,
                                               :ci_update_product_select_from_offer_item,
                                               :ci_update_amount_from_price_or_quantity,
                                               :ci_item_balance_check,
                                               :ci_item_totals,
                                               :ci_generate_invoice,
                                               :ci_current_balance,
                                               :send_invoice_form,
                                               :invoice_form,
                                               :bill_create, :bill_update]
    # Helper methods for
    # => allow edit (hide buttons)
    helper_method :cannot_edit
    # => returns client code & full name
    helper_method :client_name

    # GET /sale_offers
    # GET /sale_offers.json
    def index
      manage_filter_state
      no = params[:No]
      client = params[:Client]
      project = params[:Project]
      status = params[:Status]
      order = params[:Order]
      request = params[:Request]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = projects_dropdown if @projects.nil?
      @status = sale_offer_statuses_dropdown if @status.nil?
      @work_orders = work_orders_dropdown if @work_orders.nil?
      @contracting_requests = contracting_requests_dropdown if @contracting_requests.nil?

      # Arrays for search
      current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
      # If inverse no search is required
      no = !no.blank? && no[0] == '%' ? inverse_no_search(no) : no

      @search = SaleOffer.search do
        with :project_id, current_projects
        fulltext params[:search]
        if !no.blank?
          if no.class == Array
            with :offer_no, no
          else
            with(:offer_no).starting_with(no)
          end
        end
        if !client.blank?
          fulltext client
        end
        if !project.blank?
          with :project_id, project
        end
        if !status.blank?
          with :sale_offer_status_id, status
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @sale_offers = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sale_offers }
        format.js
      end
    end

    # GET /sale_offers/1
    # GET /sale_offers/1.json
    def show
      @sale_offer = SaleOffer.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sale_offer }
      end
    end

    # GET /sale_offers/new
    # GET /sale_offers/new.json
    def new
      @sale_offer = SaleOffer.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer }
      end
    end

    # GET /sale_offers/1/edit
    def edit
      @sale_offer = SaleOffer.find(params[:id])
    end

    # POST /sale_offers
    # POST /sale_offers.json
    def create
      @sale_offer = SaleOffer.new(params[:sale_offer])

      respond_to do |format|
        if @sale_offer.save
          format.html { redirect_to @sale_offer, notice: t('activerecord.attributes.sale_offer.create') }
          format.json { render json: @sale_offer, status: :created, location: @sale_offer }
        else
          format.html { render action: "new" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /sale_offers/1
    # PUT /sale_offers/1.json
    def update
      @sale_offer = SaleOffer.find(params[:id])

      respond_to do |format|
        if @sale_offer.update_attributes(params[:sale_offer])
          format.html { redirect_to @sale_offer, notice: t('activerecord.attributes.sale_offer.succesfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sale_offer.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sale_offers/1
    # DELETE /sale_offers/1.json
    def destroy
      @sale_offer = SaleOffer.find(params[:id])
      @sale_offer.destroy

      respond_to do |format|
        format.html { redirect_to sale_offers_url }
        format.json { head :no_content }
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Offer is totally billed
    def cannot_edit(_offer)
      !session[:is_administrator] && _offer.unbilled_balance <= 0
    end

    def client_name(_offer)
      _name = _offer.bill.client.full_name_or_company_and_code rescue nil
      _name.blank? ? '' : _name[0,40]
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
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
      _projects = Project.where(id: _array).order(:project_code)
    end

    def sale_offer_statuses_dropdown
      SaleOfferStatus.all
    end

    def work_orders_dropdown
      session[:organization] != '0' ? WorkOrder.where(organization_id: session[:organization].to_i).order(:order_no) : WorkOrder.order(:order_no)
    end

    def contracting_requests_dropdown
      session[:organization] != '0' ? ContractingRequest.belongs_to_organization(session[:organization].to_i) : ContractingRequest.by_no
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
      # status
      if params[:Status]
        session[:Status] = params[:Status]
      elsif session[:Status]
        params[:Status] = session[:Status]
      end
      # order
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
      # request
      if params[:Period]
        session[:Period] = params[:Period]
      elsif session[:Period]
        params[:Period] = session[:Period]
      end
    end
  end
end
