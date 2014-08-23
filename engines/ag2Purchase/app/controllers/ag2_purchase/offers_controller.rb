require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OffersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /offers
    # GET /offers.json
    def index
      manage_filter_state
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]

      @search = Offer.search do
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
        order_by :id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @offers = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @projects = Project.order('project_code') if @projects.nil?
      @work_orders = WorkOrder.order('order_no') if @work_orders.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offers }
        format.js
      end
    end
  
    # GET /offers/1
    # GET /offers/1.json
    def show
      @breadcrumb = 'read'
      @offer = Offer.find(params[:id])
      @items = @offer.offer_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @offer }
      end
    end
  
    # GET /offers/new
    # GET /offers/new.json
    def new
      @breadcrumb = 'create'
      @offer = Offer.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @offer }
      end
    end
  
    # GET /offers/1/edit
    def edit
      @breadcrumb = 'update'
      @offer = Offer.find(params[:id])
    end
  
    # POST /offers
    # POST /offers.json
    def create
      @breadcrumb = 'create'
      @offer = Offer.new(params[:offer])
      @offer.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer.save
          format.html { redirect_to @offer, notice: crud_notice('created', @offer) }
          format.json { render json: @offer, status: :created, location: @offer }
        else
          format.html { render action: "new" }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /offers/1
    # PUT /offers/1.json
    def update
      @breadcrumb = 'update'
      @offer = Offer.find(params[:id])
      @offer.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @offer.update_attributes(params[:offer])
          format.html { redirect_to @offer,
                        notice: (crud_notice('updated', @offer) + "#{undo_link(@offer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /offers/1
    # DELETE /offers/1.json
    def destroy
      @offer = Offer.find(params[:id])

      respond_to do |format|
        if @offer.destroy
          format.html { redirect_to offers_url,
                      notice: (crud_notice('destroyed', @offer) + "#{undo_link(@offer)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to offers_url, alert: "#{@offer.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @offer.errors, status: :unprocessable_entity }
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
