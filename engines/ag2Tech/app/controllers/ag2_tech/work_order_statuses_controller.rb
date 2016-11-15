require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderStatusesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for
    #  => sorting
    helper_method :sort_column
    # => allow edit (hide buttons)
    helper_method :cannot_edit

    # GET /work_order_statuses
    # GET /work_order_statuses.json
    def index
      manage_filter_state
      @work_order_statuses = WorkOrderStatus.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_statuses }
        format.js
      end
    end

    # GET /work_order_statuses/1
    # GET /work_order_statuses/1.json
    def show
      @breadcrumb = 'read'
      @work_order_status = WorkOrderStatus.find(params[:id])
      @worker_orders = @work_order_status.work_orders.paginate(:page => params[:page], :per_page => per_page).order('order_no')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_status }
      end
    end

    # GET /work_order_statuses/new
    # GET /work_order_statuses/new.json
    def new
      @breadcrumb = 'create'
      @work_order_status = WorkOrderStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_status }
      end
    end

    # GET /work_order_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order_status = WorkOrderStatus.find(params[:id])
    end

    # POST /work_order_statuses
    # POST /work_order_statuses.json
    def create
      @breadcrumb = 'create'
      @work_order_status = WorkOrderStatus.new(params[:work_order_status])
      @work_order_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_status.save
          format.html { redirect_to @work_order_status, notice: crud_notice('created', @work_order_status) }
          format.json { render json: @work_order_status, status: :created, location: @work_order_status }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /work_order_statuses/1
    # PUT /work_order_statuses/1.json
    def update
      @breadcrumb = 'update'
      @work_order_status = WorkOrderStatus.find(params[:id])
      @work_order_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_status.update_attributes(params[:work_order_status])
          format.html { redirect_to @work_order_status,
                        notice: (crud_notice('updated', @work_order_status) + "#{undo_link(@work_order_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /work_order_statuses/1
    # DELETE /work_order_statuses/1.json
    def destroy
      @work_order_status = WorkOrderStatus.find(params[:id])

      respond_to do |format|
        if @work_order_status.destroy
          format.html { redirect_to work_order_statuses_url,
                      notice: (crud_notice('destroyed', @work_order_status) + "#{undo_link(@work_order_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_order_statuses_url, alert: "#{@work_order_status.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order_status.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Order status ID is less than 5
    def cannot_edit(_order)
      !session[:is_administrator] && _order.id < 5
    end

    def sort_column
      WorkOrderStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
