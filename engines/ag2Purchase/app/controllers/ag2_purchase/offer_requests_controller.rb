require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OfferRequestsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /offer_requests
    # GET /offer_requests.json
    def index
      manage_filter_state
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]

      @search = OfferRequest.search do
        fulltext params[:search]
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :request_no, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @offer_requests = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @projects = Project.order('project_code') if @projects.nil?
      @work_orders = WorkOrder.order('order_no') if @work_orders.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offer_requests }
        format.js
      end
    end
  
    # GET /offer_requests/1
    # GET /offer_requests/1.json
    def show
      @breadcrumb = 'read'
      @offer_request = OfferRequest.find(params[:id])
      @items = @offer_request.offer_request_items.paginate(:page => params[:page], :per_page => per_page).order('id')
      @suppliers = @offer_request.offer_request_suppliers.paginate(:page => params[:page], :per_page => per_page).order('id')
      @offers = @offer_request.offers.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/new
    # GET /offer_requests/new.json
    def new
      @breadcrumb = 'create'
      @offer_request = OfferRequest.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @offer_request }
      end
    end
  
    # GET /offer_requests/1/edit
    def edit
      @breadcrumb = 'update'
      @offer_request = OfferRequest.find(params[:id])
    end
  
    # POST /offer_requests
    # POST /offer_requests.json
    def create
      @breadcrumb = 'create'
      @offer_request = OfferRequest.new(params[:offer_request])
      @offer_request.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer_request.save
          format.html { redirect_to @offer_request, notice: crud_notice('created', @offer_request) }
          format.json { render json: @offer_request, status: :created, location: @offer_request }
        else
          format.html { render action: "new" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /offer_requests/1
    # PUT /offer_requests/1.json
    def update
      @breadcrumb = 'update'
      @offer_request = OfferRequest.find(params[:id])
      @offer_request.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer_request.update_attributes(params[:offer_request])
          format.html { redirect_to @offer_request,
                        notice: (crud_notice('updated', @offer_request) + "#{undo_link(@offer_request)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /offer_requests/1
    # DELETE /offer_requests/1.json
    def destroy
      @offer_request = OfferRequest.find(params[:id])

      respond_to do |format|
        if @offer_request.destroy
          format.html { redirect_to offer_requests_url,
                      notice: (crud_notice('destroyed', @offer_request) + "#{undo_link(@offer_request)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to offer_requests_url, alert: "#{@offer_request.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @offer_request.errors, status: :unprocessable_entity }
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
      # supplier
      if params[:Supplier]
        session[:Supplier] = params[:Supplier]
      elsif session[:Supplier]
        params[:Supplier] = session[:Supplier]
      end
      # project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end
      # order
      if params[:Order]
        session[:Order] = params[:Order]
      elsif session[:Order]
        params[:Order] = session[:Order]
      end
    end
  end
end
