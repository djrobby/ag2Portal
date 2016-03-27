require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ApiWorkOrdersController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    skip_load_and_authorize_resource
    #load_and_authorize_resource :class => WorkOrder
    #load_and_authorize_resource :class => false

    # GET /api/work_orders
    def all
      @work_orders = WorkOrder.order(:order_no)
      render json: @work_orders
    end

    # GET /api/work_orders/by_project/1
    def by_project
      if params.has_key?(:project_id) && params[:project_id] != '0'
        @work_orders = WorkOrder.where(project_id: params[:project_id]).order(:order_no)
        render json: @work_orders
      else
        render json: :bad_request, status: :bad_request
        #render nothing: true, status: :bad_request
      end
    end
  end
end
