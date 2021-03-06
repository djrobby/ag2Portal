require_dependency "ag2_tech/application_controller"

module Ag2Tech
  #class Api::V1::WorkOrdersController < ApplicationController
  class Api::V1::WorkOrdersController < ::Api::V1::BaseController
    #include ActionView::Helpers::NumberHelper
    #before_filter :authenticate_user!
    #skip_load_and_authorize_resource
    #load_and_authorize_resource :class => WorkOrder
    #load_and_authorize_resource :class => false

    before_filter :find_work_order, only: [:destroy, :update]
    before_filter :find_work_order_item, only: [:destroy_item, :update_item, :item, :item_header]
    before_filter :find_work_order_items, only: [:items, :item_headers]
    before_filter :find_work_order_worker, only: [:destroy_worker, :update_worker, :worker, :worker_header]
    before_filter :find_work_order_workers, only: [:workers, :worker_headers]
    before_filter :find_work_order_tool, only: [:destroy_tool, :update_tool, :tool, :tool_header]
    before_filter :find_work_order_tools, only: [:tools, :tool_headers]
    before_filter :find_work_order_vehicle, only: [:destroy_vehicle, :update_vehicle, :vehicle, :vehicle_header]
    before_filter :find_work_order_vehicles, only: [:vehicles, :vehicle_headers]
    before_filter :find_work_order_subcontractor, only: [:destroy_subcontractor, :update_subcontractor, :subcontractor, :subcontractor_header]
    before_filter :find_work_order_subcontractors, only: [:subcontractors, :subcontractor_headers]

    before_filter only: :create do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order = WorkOrder.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
        #render nothing: true, status: :bad_request
      end
    end

    before_filter only: :create_item do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order_item = WorkOrderItem.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
      end
    end

    before_filter only: :create_worker do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order_worker = WorkOrderWorker.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
      end
    end

    before_filter only: :create_tool do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order_tool = WorkOrderTool.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
      end
    end

    before_filter only: :create_vehicle do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order_vehicle = WorkOrderVehicle.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
      end
    end

    before_filter only: :create_subcontractor do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order_subcontractor = WorkOrderSubcontractor.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
      end
    end

    # before_filter only: :create do
    #   unless @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
    #     render json: :bad_request, status: :bad_request
    #     #render nothing: true, status: :bad_request
    #   end
    # end

    # before_filter only: :create do
    #   @work_order = WorkOrder.find(@json['data']['id']) rescue nil
    # end

    # ag2Tech API: R (Queries)
    # returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    # REST parameters => (<param>): optional
    #               project_id: project id
    #               id: work order id
    #
    # General:
    # GET /api/v1/work_orders/<method>[/<param>]?<auth>
    #
    # GET /api/v1/work_orders => all (includes items)
    # GET /api/v1/work_orders/headers => headers (no items)
    # GET /api/v1/work_orders/:id => one (includes items)
    # GET /api/v1/work_orders/headers/:id => header (one, no items)
    # GET /api/v1/work_orders/by_project/:project_id => by_project (includes items)
    # GET /api/v1/work_orders/headers_by_project/:project_id => headers_by_project (no items)
    # GET /api/v1/work_orders/unstarted(/:project_id) => unstarted ones
    # GET /api/v1/work_orders/uncompleted(/:project_id) => started by uncompleted ones
    # GET /api/v1/work_orders/unclosed(/:project_id) => completed but unclosed ones
    # GET /api/v1/work_orders/closed(/:project_id) => closed ones
    #
    # Linked models:
    #
    # GET /api/v1/work_order_items/ => all (includes FK data)
    # GET /api/v1/work_order_items/by_order/:work_order_id => work order items (includes FK data)
    # GET /api/v1/work_order_items/headers_by_order/:work_order_id => work order items headers (no FK)
    # GET /api/v1/work_order_items/headers/:id => work order item header (one, no FK)
    # GET /api/v1/work_order_items/:id => work order item (includes FK data)
    #
    # GET /api/v1/work_order_workers/ => all (includes FK data)
    # GET /api/v1/work_order_workers/by_order/:work_order_id => work order workers (includes FK data)
    # GET /api/v1/work_order_workers/headers_by_order/:work_order_id => work order workers headers (no FK)
    # GET /api/v1/work_order_workers/headers/:id => work order worker header (one, no FK)
    # GET /api/v1/work_order_workers/:id => work order worker (includes FK data)
    #
    # GET /api/v1/work_order_tools/ => all (includes FK data)
    # GET /api/v1/work_order_tools/by_order/:work_order_id => work order tools (includes FK data)
    # GET /api/v1/work_order_tools/headers_by_order/:work_order_id => work order tools headers (no FK)
    # GET /api/v1/work_order_tools/headers/:id => work order tool header (one, no FK)
    # GET /api/v1/work_order_tools/:id => work order tool (includes FK data)
    #
    # GET /api/v1/work_order_vehicles/ => all (includes FK data)
    # GET /api/v1/work_order_vehicles/by_order/:work_order_id => work order vehicles (includes FK data)
    # GET /api/v1/work_order_vehicles/headers_by_order/:work_order_id => work order vehicles headers (no FK)
    # GET /api/v1/work_order_vehicles/headers/:id => work order vehicle header (one, no FK)
    # GET /api/v1/work_order_vehicles/:id => work order vehicle (includes FK data)
    #
    # GET /api/v1/work_order_subcontractors/ => all (includes FK data)
    # GET /api/v1/work_order_subcontractors/by_order/:work_order_id => work order subcontractors (includes FK data)
    # GET /api/v1/work_order_subcontractors/headers_by_order/:work_order_id => work order subcontractors headers (no FK)
    # GET /api/v1/work_order_subcontractors/headers/:id => work order subcontractor header (one, no FK)
    # GET /api/v1/work_order_subcontractors/:id => work order subcontractor (includes FK data)
    #
    # Auxilary:
    # GET /api/v1/work_order_<aux>/<method>[/<param>]?<auth>
    # REST parameters => (<param>): optional
    #               id: work order <aux> id
    #
    # GET /api/v1/work_order_areas/ => areas (include FK data)
    # GET /api/v1/work_order_areas/headers => headers (no FK)
    # GET /api/v1/work_order_areas/:id => area (include FK data)
    # GET /api/v1/work_order_areas/headers/:id => header (one, no FK)
    # GET /api/v1/work_order_types/ => types
    # GET /api/v1/work_order_types/headers => headers (no FK)
    # GET /api/v1/work_order_types/:id => type
    # GET /api/v1/work_order_types/headers/:id => header (one, no FK)
    # GET /api/v1/work_order_statuses/ => statuses
    # GET /api/v1/work_order_statuses/:id => status
    # GET /api/v1/work_order_labors/ => labors
    # GET /api/v1/work_order_labors/headers => headers (no FK)
    # GET /api/v1/work_order_labors/:id => labor
    # GET /api/v1/work_order_labors/headers/:id => headers (no FK)
    # GET /api/v1/work_order_infrastructures/ => infrastructures
    # GET /api/v1/work_order_infrastructures/headers => headers (no FK)
    # GET /api/v1/work_order_infrastructures/:id => infrastructure
    # GET /api/v1/work_order_infrastructures/headers/:id => headers (no FK)

    # GET /api/work_orders
    def all
      work_orders = WorkOrder.by_no
      render json: serialized_work_orders(work_orders)
    end

    # GET /api/work_orders/headers/
    def headers
      work_orders = WorkOrder.by_no
      render json: serialized_work_orders_header(work_orders)
    end

    # GET /api/work_orders/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        work_order = WorkOrder.find(params[:id]) rescue nil
        if !work_order.blank?
          render json: Api::V1::WorkOrdersSerializer.new(work_order)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/header/:id
    def header
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        work_order = WorkOrder.find(params[:id]) rescue nil
        if !work_order.blank?
          render json: Api::V1::WorkOrdersHeaderSerializer.new(work_order, root: 'work_orders')
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/by_project/:project_id
    def by_project
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.belongs_to_project(params[:project_id])
        if !work_orders.blank?
          render json: serialized_work_orders(work_orders)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    # GET /api/work_orders/headers_by_project/:project_id
    def headers_by_project
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.belongs_to_project(params[:project_id])
        if !work_orders.blank?
          render json: serialized_work_orders_header(work_orders)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    # Unstarted
    # GET /api/work_orders/unstarted(/:project_id)
    def unstarted
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.unstarted(params[:project_id])
      else
        work_orders = WorkOrder.unstarted
      end
      if !work_orders.blank?
        render json: serialized_work_orders(work_orders)
      else
        render json: :not_found, status: :not_found
      end
    end

    # Started but uncompleted
    # GET /api/work_orders/uncompleted(/:project_id)
    def uncompleted
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.uncompleted(params[:project_id])
      else
        work_orders = WorkOrder.uncompleted
      end
      if !work_orders.blank?
        render json: serialized_work_orders(work_orders)
      else
        render json: :not_found, status: :not_found
      end
    end

    # Completed but unclosed
    # GET /api/work_orders/unclosed(/:project_id)
    def unclosed
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.unclosed(params[:project_id])
      else
        work_orders = WorkOrder.unclosed
      end
      if !work_orders.blank?
        render json: serialized_work_orders(work_orders)
      else
        render json: :not_found, status: :not_found
      end
    end

    # Closed
    # GET /api/work_orders/closed(/:project_id)
    def closed
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        work_orders = WorkOrder.closed(params[:project_id])
      else
        work_orders = WorkOrder.closed
      end
      if !work_orders.blank?
        render json: serialized_work_orders(work_orders)
      else
        render json: :not_found, status: :not_found
      end
    end

    #
    # Auxiliary models
    #
    # Work order Areas
    # GET /api/work_orders/areas
    def areas
      aux = WorkOrderArea.by_name
      render json: serialized_work_order_areas(aux)
    end

    # GET /api/work_orders/areas/headers/
    def area_headers
      aux = WorkOrderArea.by_name
      render json: serialized_work_order_areas_header(aux)
    end

    # GET /api/work_orders/areas/:id
    def area
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderArea.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderAreasSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/areas/header/:id
    def area_header
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderArea.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderAreasHeaderSerializer.new(aux, root: 'work_order_areas')
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # Work order Types
    # GET /api/work_orders/types
    def types
      aux = WorkOrderType.by_name
      render json: serialized_work_order_types(aux)
    end

    # GET /api/work_orders/types/headers/
    def type_headers
      aux = WorkOrderType.by_name
      render json: serialized_work_order_types_header(aux)
    end

    # GET /api/work_orders/types/:id
    def type
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderType.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderTypesSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/types/header/:id
    def type_header
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderType.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderTypesHeaderSerializer.new(aux, root: 'work_order_types')
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # Work order Statuses
    # GET /api/work_orders/statuses
    def statuses
      aux = WorkOrderStatus.all
      render json: serialized_work_order_statuses(aux)
    end

    # GET /api/work_orders/statuses/:id
    def status
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderStatus.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderStatusesSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # Work order Labors
    # GET /api/work_orders/labors
    def labors
      aux = WorkOrderLabor.by_name
      render json: serialized_work_order_labors(aux)
    end

    # GET /api/work_orders/labors/headers
    def labor_headers
      aux = WorkOrderLabor.by_name
      render json: serialized_work_order_labors_header(aux)
    end

    # GET /api/work_orders/labors/:id
    def labor
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderLabor.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderLaborsSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/labor/headers/:id
    def labor_header
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = WorkOrderLabor.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderLaborsHeaderSerializer.new(aux, root: 'work_order_labors')
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # Work order Infrastructures
    # GET /api/work_orders/infrastructures
    def infrastructures
      aux = Infrastructure.by_code
      render json: serialized_work_order_infrastructures(aux)
    end

    # GET /api/work_orders/infrastructures/headers
    def infrastructure_headers
      aux = Infrastructure.by_code
      render json: serialized_work_order_infrastructures_header(aux)
    end

    # GET /api/work_orders/infrastructures/:id
    def infrastructure
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = Infrastructure.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderInfrastructuresSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/work_orders/infrastructure/headers/:id
    def infrastructure_header
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        aux = Infrastructure.find(params[:id]) rescue nil
        if !aux.blank?
          render json: Api::V1::WorkOrderInfrastructuresHeaderSerializer.new(aux, root: 'work_order_infrastructures')
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    #
    # Linked models (R)
    #
    # Work order Items
    # GET /api/work_order_items
    def items_all
      @work_order_items = WorkOrderItem.by_id
      render json: serialized_work_order_items(@work_order_items)
    end

    # GET /api/work_order/items/:work_order_id
    def items
      render json: serialized_work_order_items(@work_order_items)
    end

    # GET /api/work_order/items/headers/:work_order_id
    def item_headers
      render json: serialized_work_order_items_header(@work_order_items)
    end

    # GET /api/work_order/items/:id
    def item
      render json: Api::V1::WorkOrderItemsSerializer.new(@work_order_item)
    end

    # GET /api/work_order/items/header/:id
    def item_header
      render json: Api::V1::WorkOrderItemsHeaderSerializer.new(@work_order_item, root: 'work_order_items')
    end

    # Work order Workers
    # GET /api/work_order_workers
    def workers_all
      @work_order_workers = WorkOrderWorker.by_id
      render json: serialized_work_order_workers(@work_order_workers)
    end

    # GET /api/work_order/workers/:work_order_id
    def workers
      render json: serialized_work_order_workers(@work_order_workers)
    end

    # GET /api/work_order/workers/headers/:work_order_id
    def worker_headers
      render json: serialized_work_order_workers_header(@work_order_workers)
    end

    # GET /api/work_order/workers/:id
    def worker
      render json: Api::V1::WorkOrderWorkersSerializer.new(@work_order_worker)
    end

    # GET /api/work_order/workers/header/:id
    def worker_header
      render json: Api::V1::WorkOrderWorkersHeaderSerializer.new(@work_order_worker, root: 'work_order_workers')
    end

    # Work order Tools
    # GET /api/work_order_tools
    def tools_all
      @work_order_tools = WorkOrderTool.by_id
      render json: serialized_work_order_tools(@work_order_tools)
    end

    # GET /api/work_order/tools/:work_order_id
    def tools
      render json: serialized_work_order_tools(@work_order_tools)
    end

    # GET /api/work_order/tools/headers/:work_order_id
    def tool_headers
      render json: serialized_work_order_tools_header(@work_order_tools)
    end

    # GET /api/work_order/tools/:id
    def tool
      render json: Api::V1::WorkOrderToolsSerializer.new(@work_order_tool)
    end

    # GET /api/work_order/tools/header/:id
    def tool_header
      render json: Api::V1::WorkOrderToolsHeaderSerializer.new(@work_order_tool, root: 'work_order_tools')
    end

    # Work order Vehicles
    # GET /api/work_order_vehicles
    def vehicles_all
      @work_order_vehicles = WorkOrderVehicle.by_id
      render json: serialized_work_order_vehicles(@work_order_vehicles)
    end

    # GET /api/work_order/vehicles/:work_order_id
    def vehicles
      render json: serialized_work_order_vehicles(@work_order_vehicles)
    end

    # GET /api/work_order/vehicles/headers/:work_order_id
    def vehicle_headers
      render json: serialized_work_order_vehicles_header(@work_order_vehicles)
    end

    # GET /api/work_order/vehicles/:id
    def vehicle
      render json: Api::V1::WorkOrderVehiclesSerializer.new(@work_order_vehicle)
    end

    # GET /api/work_order/vehicles/header/:id
    def vehicle_header
      render json: Api::V1::WorkOrderVehiclesHeaderSerializer.new(@work_order_vehicle, root: 'work_order_vehicles')
    end

    # Work order Subcontractors
    # GET /api/work_order_subcontractors
    def subcontractors_all
      @work_order_subcontractors = WorkOrderSubcontractor.by_id
      render json: serialized_work_order_subcontractors(@work_order_subcontractors)
    end

    # GET /api/work_order/subcontractors/:work_order_id
    def subcontractors
      render json: serialized_work_order_subcontractors(@work_order_subcontractors)
    end

    # GET /api/work_order/subcontractors/headers/:work_order_id
    def subcontractor_headers
      render json: serialized_work_order_subcontractors_header(@work_order_subcontractors)
    end

    # GET /api/work_order/subcontractors/:id
    def subcontractor
      render json: Api::V1::WorkOrderSubcontractorsSerializer.new(@work_order_subcontractor)
    end

    # GET /api/work_order/subcontractors/header/:id
    def subcontractor_header
      render json: Api::V1::WorkOrderSubcontractorsHeaderSerializer.new(@work_order_subcontractor, root: 'work_order_subcontractors')
    end

    # ag2Tech API: CUD (Create, Update & Delete)
    # accepts JSON, returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    #               data (JSON): work order data (C mandatory) (curl -d)
    # REST parameters => id: work order id
    #
    # RETURN statuses / JSON (lower case) =>
    #   C:  409 conflict (already exists) / CONFLICT
    #       422 unprocessable entity (can't save, data error) / WORK_ORDER_ERRORS
    #       201 created (created) / WORK_ORDER_DATA
    #   U:  400 bad request (bad id) / BAD_REQUEST
    #       404 not found (can't find id) / NOT_FOUND
    #       422 unprocessable entity (can't update) / WORK_ORDER_ERRORS
    #       200 no error (updated) / WORK_ORDER_DATA
    #   D:  400 bad request (bad id) / BAD_REQUEST
    #       404 not found (can't find id) / NOT_FOUND
    #       422 unprocessable entity (can't delete) / WORK_ORDER_ERRORS
    #       200 no error (deleted) / DELETED
    #
    # POST /api/v1/work_orders/ => create new <data>
    # PUT /api/v1/work_orders/:id => update existing <id><data>
    # DELETE /api/v1/work_orders/:id => delete existing <id>
    #
    # Linked models:
    #
    # POST /api/v1/work_order_items/ => create new item <data>
    # PUT /api/v1/work_order_items/:id => update existing item <id><data>
    # DELETE /api/v1/work_order_items/:id => delete existing item <id>
    #
    # POST /api/v1/work_order_workers/ => create new worker <data>
    # PUT /api/v1/work_order_workers/:id => update existing worker <id><data>
    # DELETE /api/v1/work_order_workers/:id => delete existing worker <id>
    #
    # POST /api/v1/work_order_tools/ => create new tool <data>
    # PUT /api/v1/work_order_tools/:id => update existing tool <id><data>
    # DELETE /api/v1/work_order_tools/:id => delete existing tool <id>
    #
    # POST /api/v1/work_order_vehicles/ => create new vehicle <data>
    # PUT /api/v1/work_order_vehicles/:id => update existing vehicle <id><data>
    # DELETE /api/v1/work_order_vehicles/:id => delete existing vehicle <id>
    #
    # POST /api/v1/work_order_subcontractors/ => create new subcontractor <data>
    # PUT /api/v1/work_order_subcontractors/:id => update existing subcontractor <id><data>
    # DELETE /api/v1/work_order_subcontractors/:id => delete existing subcontractor <id>

    # POST /api/work_orders
    def create
      if @work_order_item.present?
        render json: :conflict, status: :conflict
      else
        @work_order_item = WorkOrderItem.new
        @work_order_item.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_item.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_item.save
          render json: serialized_work_order(@work_order_item), status: :created
        else
           render json: format_errors(@work_order_item), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_orders/:id
    def update
      @work_order.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order.save
        render json: serialized_work_order(@work_order), status: :ok
      else
        render json: format_errors(@work_order), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_orders/:id
    def destroy
      if @work_order.destroy
        #head :no_content
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order), status: :unprocessable_entity
      end
    end

    #
    # Linked models (CUD)
    #
    # Work order Items
    # POST /api/work_order_items
    def create_item
      if @work_order_item.present?
        render json: :conflict, status: :conflict
      else
        @work_order_item = WorkOrderItem.new
        @work_order_item.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_item.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_item.save
          render json: serialized_work_order_item(@work_order_item), status: :created
        else
           render json: format_errors(@work_order_item), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_items/:id
    def update_item
      @work_order_item.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order_item.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order_item.save
        render json: serialized_work_order_item(@work_order_item), status: :ok
      else
        render json: format_errors(@work_order_item), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_order_items/:id
    def destroy_item
      if @work_order_item.destroy
        #head :no_content
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order_item), status: :unprocessable_entity
      end
    end

    # Work order Workers
    # POST /api/work_order_workers
    def create_worker
      if @work_order_worker.present?
        render json: :conflict, status: :conflict
      else
        @work_order_worker = WorkOrderWorker.new
        @work_order_worker.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_worker.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_worker.save
          render json: serialized_work_order_worker(@work_order_worker), status: :created
        else
           render json: format_errors(@work_order_worker), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_workers/:id
    def update_worker
      @work_order_worker.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order_worker.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order_worker.save
        render json: serialized_work_order_worker(@work_order_worker), status: :ok
      else
        render json: format_errors(@work_order_worker), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_order_workers/:id
    def destroy_worker
      if @work_order_worker.destroy
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order_worker), status: :unprocessable_entity
      end
    end

    # Work order Tools
    # POST /api/work_order_tools
    def create_tool
      if @work_order_tool.present?
        render json: :conflict, status: :conflict
      else
        @work_order_tool = WorkOrderTool.new
        @work_order_tool.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_tool.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_tool.save
          render json: serialized_work_order_tool(@work_order_tool), status: :created
        else
           render json: format_errors(@work_order_tool), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_tools/:id
    def update_tool
      @work_order_tool.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order_tool.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order_tool.save
        render json: serialized_work_order_tool(@work_order_tool), status: :ok
      else
        render json: format_errors(@work_order_tool), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_order_tools/:id
    def destroy_tool
      if @work_order_tool.destroy
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order_tool), status: :unprocessable_entity
      end
    end

    # Work order Vehicles
    # POST /api/work_order_vehicles
    def create_vehicle
      if @work_order_vehicle.present?
        render json: :conflict, status: :conflict
      else
        @work_order_vehicle = WorkOrderVehicle.new
        @work_order_vehicle.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_vehicle.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_vehicle.save
          render json: serialized_work_order_vehicle(@work_order_vehicle), status: :created
        else
           render json: format_errors(@work_order_vehicle), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_vehicles/:id
    def update_vehicle
      @work_order_vehicle.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order_vehicle.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order_vehicle.save
        render json: serialized_work_order_vehicle(@work_order_vehicle), status: :ok
      else
        render json: format_errors(@work_order_vehicle), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_order_vehicles/:id
    def destroy_vehicle
      if @work_order_vehicle.destroy
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order_vehicle), status: :unprocessable_entity
      end
    end

    # Work order Subcontractors
    # POST /api/work_order_subcontractors
    def create_subcontractor
      if @work_order_subcontractor.present?
        render json: :conflict, status: :conflict
      else
        @work_order_subcontractor = WorkOrderVehicle.new
        @work_order_subcontractor.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order_subcontractor.created_by = current_user.id if !current_user.nil?
        end
        if @work_order_subcontractor.save
          render json: serialized_work_order_subcontractor(@work_order_subcontractor), status: :created
        else
           render json: format_errors(@work_order_subcontractor), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_subcontractors/:id
    def update_subcontractor
      @work_order_subcontractor.assign_attributes(@json['data'])
      if !@json['data']['updated_by']
        @work_order_subcontractor.updated_by = current_user.id if !current_user.nil?
      end
      if @work_order_subcontractor.save
        render json: serialized_work_order_subcontractor(@work_order_subcontractor), status: :ok
      else
        render json: format_errors(@work_order_subcontractor), status: :unprocessable_entity
      end
    end

    # DELETE /api/work_order_subcontractors/:id
    def destroy_subcontractor
      if @work_order_subcontractor.destroy
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order_subcontractor), status: :unprocessable_entity
      end
    end

    #-----#
    private

    #
    # Before filter methods
    #
    # Returns searched WorkOrder
    def find_work_order
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order = WorkOrder.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order.present?
      end
    end

    # Returns searched WorkOrderItem
    def find_work_order_item
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_item = WorkOrderItem.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order_item.present?
      end
    end

    # Returns searched WorkOrder's Items
    def find_work_order_items
      if !params.has_key?(:work_order_id) || !is_numeric?(params[:work_order_id]) || params[:work_order_id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_items = WorkOrderItem.belongs_to_work_order(params[:work_order_id])
        render json: :not_found, status: :not_found unless @work_order_items.present?
      end
    end

    # Returns searched WorkOrderWorker
    def find_work_order_worker
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_worker = WorkOrderWorker.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order_worker.present?
      end
    end

    # Returns searched WorkOrder's Workers
    def find_work_order_workers
      if !params.has_key?(:work_order_id) || !is_numeric?(params[:work_order_id]) || params[:work_order_id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_workers = WorkOrderWorker.belongs_to_work_order(params[:work_order_id])
        render json: :not_found, status: :not_found unless @work_order_workers.present?
      end
    end

    # Returns searched WorkOrderTool
    def find_work_order_tool
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_tool = WorkOrderTool.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order_tool.present?
      end
    end

    # Returns searched WorkOrder's Tools
    def find_work_order_tools
      if !params.has_key?(:work_order_id) || !is_numeric?(params[:work_order_id]) || params[:work_order_id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_tools = WorkOrderTool.belongs_to_work_order(params[:work_order_id])
        render json: :not_found, status: :not_found unless @work_order_tools.present?
      end
    end

    # Returns searched WorkOrderVehicle
    def find_work_order_vehicle
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_vehicle = WorkOrderVehicle.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order_vehicle.present?
      end
    end

    # Returns searched WorkOrder's Vehicles
    def find_work_order_vehicles
      if !params.has_key?(:work_order_id) || !is_numeric?(params[:work_order_id]) || params[:work_order_id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_vehicles = WorkOrderVehicle.belongs_to_work_order(params[:work_order_id])
        render json: :not_found, status: :not_found unless @work_order_vehicles.present?
      end
    end

    # Returns searched WorkOrderSubcontractor
    def find_work_order_subcontractor
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_subcontractor = WorkOrderSubcontractor.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order_subcontractor.present?
      end
    end

    # Returns searched WorkOrder's Subcontractors
    def find_work_order_subcontractors
      if !params.has_key?(:work_order_id) || !is_numeric?(params[:work_order_id]) || params[:work_order_id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order_subcontractors = WorkOrderSubcontractor.belongs_to_work_order(params[:work_order_id])
        render json: :not_found, status: :not_found unless @work_order_subcontractors.present?
      end
    end

    #
    # Aux functions
    #
    # Returns errors as JSON
    def format_errors(_data)
      _data.errors.as_json
    end

    # Returns JSON formatted order
    def serialized_work_order(_data)
      Api::V1::WorkOrdersSerializer.new(_data)
    end

    # Returns JSON list of orders
    def serialized_work_orders(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::WorkOrdersSerializer, root: 'work_orders')
    end

    def serialized_work_orders_header(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::WorkOrdersHeaderSerializer, root: 'work_orders')
    end

    def serialized_work_order_areas(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderAreasSerializer, root: 'work_order_areas')
    end

    def serialized_work_order_areas_header(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderAreasHeaderSerializer, root: 'work_order_areas')
    end

    def serialized_work_order_types(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderTypesSerializer, root: 'work_order_types')
    end

    def serialized_work_order_types_header(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderTypesHeaderSerializer, root: 'work_order_types')
    end

    def serialized_work_order_statuses(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderStatusesSerializer, root: 'work_order_statuses')
    end

    def serialized_work_order_labors(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderLaborsSerializer, root: 'work_order_labors')
    end

    def serialized_work_order_labors_header(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderLaborsHeaderSerializer, root: 'work_order_labors')
    end

    def serialized_work_order_infrastructures(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderInfrastructuresSerializer, root: 'work_order_infrastructures')
    end

    def serialized_work_order_infrastructures_header(_aux)
      ActiveModel::ArraySerializer.new(_aux, each_serializer: Api::V1::WorkOrderInfrastructuresHeaderSerializer, root: 'work_order_infrastructures')
    end

    def serialized_work_order_items(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderItemsSerializer, root: 'work_order_items')
    end

    def serialized_work_order_items_header(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderItemsHeaderSerializer, root: 'work_order_items')
    end

    def serialized_work_order_workers(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderWorkersSerializer, root: 'work_order_workers')
    end

    def serialized_work_order_workers_header(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderWorkersHeaderSerializer, root: 'work_order_workers')
    end

    def serialized_work_order_tools(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderToolsSerializer, root: 'work_order_tools')
    end

    def serialized_work_order_tools_header(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderToolsHeaderSerializer, root: 'work_order_tools')
    end

    def serialized_work_order_vehicles(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderVehiclesSerializer, root: 'work_order_vehicles')
    end

    def serialized_work_order_vehicles_header(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderVehiclesHeaderSerializer, root: 'work_order_vehicles')
    end

    def serialized_work_order_subcontractors(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderSubcontractorsSerializer, root: 'work_order_subcontractors')
    end

    def serialized_work_order_subcontractors_header(_item)
      ActiveModel::ArraySerializer.new(_item, each_serializer: Api::V1::WorkOrderSubcontractorsHeaderSerializer, root: 'work_order_subcontractors')
    end  end
end
