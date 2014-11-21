require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class OrderStatusesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /order_statuses
    # GET /order_statuses.json
    def index
      manage_filter_state
      @order_statuses = OrderStatus.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @order_statuses }
        format.js
      end
    end
  
    # GET /order_statuses/1
    # GET /order_statuses/1.json
    def show
      @breadcrumb = 'read'
      @order_status = OrderStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @order_status }
        format.js
      end
    end
  
    # GET /order_statuses/new
    # GET /order_statuses/new.json
    def new
      @breadcrumb = 'create'
      @order_status = OrderStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @order_status }
      end
    end
  
    # GET /order_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @order_status = OrderStatus.find(params[:id])
    end
  
    # POST /order_statuses
    # POST /order_statuses.json
    def create
      @breadcrumb = 'create'
      @order_status = OrderStatus.new(params[:order_status])
      @order_status.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @order_status.save
          format.html { redirect_to @order_status, notice: crud_notice('created', @order_status) }
          format.json { render json: @order_status, status: :created, location: @order_status }
        else
          format.html { render action: "new" }
          format.json { render json: @order_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /order_statuses/1
    # PUT /order_statuses/1.json
    def update
      @breadcrumb = 'update'
      @order_status = OrderStatus.find(params[:id])
      @order_status.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @order_status.update_attributes(params[:order_status])
          format.html { redirect_to @order_status,
                        notice: (crud_notice('updated', @order_status) + "#{undo_link(@order_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @order_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /order_statuses/1
    # DELETE /order_statuses/1.json
    def destroy
      @order_status = OrderStatus.find(params[:id])

      respond_to do |format|
        if @order_status.destroy
          format.html { redirect_to order_statuses_url,
                      notice: (crud_notice('destroyed', @order_status) + "#{undo_link(@order_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to order_statuses_url, alert: "#{@order_status.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @order_status.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      OrderStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
