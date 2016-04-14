require_dependency "ag2_tech/application_controller"

module Ag2Tech
  #class Api::V1::WorkOrdersController < ApplicationController
  class Api::V1::WorkOrdersController < ::Api::V1::BaseController
    #include ActionView::Helpers::NumberHelper
    #before_filter :authenticate_user!
    #skip_load_and_authorize_resource
    #load_and_authorize_resource :class => WorkOrder
    #load_and_authorize_resource :class => false

    # ag2Tech API
    # returns JSON
    # scope => /ag2_tech
    # parameters => (<param>): optional
    #               project_id: project id
    #               id: work order id
    #
    # GET /api/v1/work_orders => all
    # GET /api/v1/work_orders/:id => one
    # GET /api/v1/work_orders/by_project/:project_id => by_project
    # GET /api/v1/work_orders/unstarted(/:project_id) => unstarted ones
    # GET /api/v1/work_orders/uncompleted(/:project_id) => started by uncompleted ones
    # GET /api/v1/work_orders/unclosed(/:project_id) => completed but unclosed ones
    # GET /api/v1/work_orders/closed(/:project_id) => closed ones

    # GET /api/work_orders
    def all
      @work_orders = WorkOrder.order(:order_no)
      render json: @work_orders
    end

    # GET /api/work_orders/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order = WorkOrder.find(params[:id]) rescue nil
        if !@work_order.blank?
          @items = @work_order.work_order_items.paginate(:page => params[:page], :per_page => per_page).order('id')
          @workers = @work_order.work_order_workers.paginate(:page => params[:page], :per_page => per_page).order('id')
          @subcontractors = @work_order.work_order_subcontractors.paginate(:page => params[:page], :per_page => per_page).order('id')
          @tools = @work_order.work_order_tools.paginate(:page => params[:page], :per_page => per_page).order('id')
          @vehicles = @work_order.work_order_vehicles.paginate(:page => params[:page], :per_page => per_page).order('id')
          render json: @work_order
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/by_project/:project_id
    def by_project
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        @work_orders = WorkOrder.where(project_id: params[:project_id]).order(:order_no)
        if !@work_orders.blank?
          render json: @work_orders
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
        #render nothing: true, status: :bad_request
      end
    end

    # Unstarted
    # GET /api/work_orders/unstarted(/:project_id)
    def unstarted
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        @work_orders = WorkOrder.unstarted(params[:project_id])
      else
        @work_orders = WorkOrder.unstarted
      end
      if !@work_orders.blank?
        render json: @work_orders
      else
        render json: :not_found, status: :not_found
      end
    end

    # Started but uncompleted
    # GET /api/work_orders/uncompleted(/:project_id)
    def uncompleted
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        @work_orders = WorkOrder.uncompleted(params[:project_id])
      else
        @work_orders = WorkOrder.uncompleted
      end
      if !@work_orders.blank?
        render json: @work_orders
      else
        render json: :not_found, status: :not_found
      end
    end

    # Completed but unclosed
    # GET /api/work_orders/unclosed(/:project_id)
    def unclosed
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        @work_orders = WorkOrder.unclosed(params[:project_id])
      else
        @work_orders = WorkOrder.unclosed
      end
      if !@work_orders.blank?
        render json: @work_orders
      else
        render json: :not_found, status: :not_found
      end
    end

    # Closed
    # GET /api/work_orders/closed(/:project_id)
    def closed
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        @work_orders = WorkOrder.closed(params[:project_id])
      else
        @work_orders = WorkOrder.closed
      end
      if !@work_orders.blank?
        render json: @work_orders
      else
        render json: :not_found, status: :not_found
      end
    end
  end
end