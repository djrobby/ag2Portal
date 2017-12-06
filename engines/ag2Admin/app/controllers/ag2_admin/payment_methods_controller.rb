require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class PaymentMethodsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:pm_format_numbers]
    # Helper methods for sorting
    helper_method :sort_column

    # Format numbers properly
    def pm_format_numbers
      num = params[:num].to_f / 1000
      num = number_with_precision(num.round(3), precision: 3)
      @json_data = { "num" => num.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /payment_methods
    # GET /payment_methods.json
    def index
      manage_filter_state
      filter = params[:ifilter]
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @payment_methods = flow_filter_organization(filter, session[:organization].to_i)
      else
        @payment_methods = flow_filter(filter)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @payment_methods }
        format.js
      end
    end

    # GET /payment_methods/1
    # GET /payment_methods/1.json
    def show
      @breadcrumb = 'read'
      @payment_method = PaymentMethod.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @payment_method }
      end
    end

    # GET /payment_methods/new
    # GET /payment_methods/new.json
    def new
      @breadcrumb = 'create'
      @payment_method = PaymentMethod.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @payment_method }
      end
    end

    # GET /payment_methods/1/edit
    def edit
      @breadcrumb = 'update'
      @payment_method = PaymentMethod.find(params[:id])
    end

    # POST /payment_methods
    # POST /payment_methods.json
    def create
      @breadcrumb = 'create'
      @payment_method = PaymentMethod.new(params[:payment_method])
      @payment_method.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @payment_method.save
          format.html { redirect_to @payment_method, notice: crud_notice('created', @payment_method) }
          format.json { render json: @payment_method, status: :created, location: @payment_method }
        else
          format.html { render action: "new" }
          format.json { render json: @payment_method.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /payment_methods/1
    # PUT /payment_methods/1.json
    def update
      @breadcrumb = 'update'
      @payment_method = PaymentMethod.find(params[:id])
      @payment_method.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @payment_method.update_attributes(params[:payment_method])
          format.html { redirect_to @payment_method,
                        notice: (crud_notice('updated', @payment_method) + "#{undo_link(@payment_method)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @payment_method.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /payment_methods/1
    # DELETE /payment_methods/1.json
    def destroy
      @payment_method = PaymentMethod.find(params[:id])

      respond_to do |format|
        if @payment_method.destroy
          format.html { redirect_to payment_methods_url,
                      notice: (crud_notice('destroyed', @payment_method) + "#{undo_link(@payment_method)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to payment_methods_url, alert: "#{@payment_method.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @payment_method.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def flow_filter(_filter)
      if _filter == "all"
        _methods = PaymentMethod.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "collection"
        _methods = PaymentMethod.where("flow = 3 OR flow = 1").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "payment"
        _methods = PaymentMethod.where("flow = 3 OR flow = 2").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _methods = PaymentMethod.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _methods
    end

    def flow_filter_organization(_filter, _organization)
      if _filter == "all"
        _methods = PaymentMethod.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "collection"
        _methods = PaymentMethod.where("(flow = 3 OR flow = 1) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "payment"
        _methods = PaymentMethod.where("(flow = 3 OR flow = 2) AND organization_id = ?", _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        _methods = PaymentMethod.where(organization_id: _organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
      _methods
    end

    def sort_column
      PaymentMethod.column_names.include?(params[:sort]) ? params[:sort] : "description"
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
      # ifilter
      if params[:ifilter]
        session[:ifilter] = params[:ifilter]
      elsif session[:ifilter]
        params[:ifilter] = session[:ifilter]
      end
    end
  end
end
