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

    before_filter only: :create do
      if @json.has_key?('data') && @json['data'].respond_to?(:[]) && @json['data']['id']
        @work_order = WorkOrder.find(@json['data']['id']) rescue nil
      else
        render json: :bad_request, status: :bad_request
        #render nothing: true, status: :bad_request
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
          render json: Api::V1::WorkOrderAreasHeaderSerializer.new(aux)
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
          render json: Api::V1::WorkOrderTypesHeaderSerializer.new(aux)
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
          render json: Api::V1::WorkOrderLaborsHeaderSerializer.new(aux)
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
          render json: Api::V1::WorkOrderInfrastructuresHeaderSerializer.new(aux)
        else
          render json: :not_found, status: :not_found
        end
      end
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

    # POST /api/work_orders
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
          render json: serialized_work_order(@work_order_item), status: :created
        else
           render json: format_errors(@work_order_item), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_orders/:id
    def update_item
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
    def destroy_item
      if @work_order.destroy
        #head :no_content
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order), status: :unprocessable_entity
      end
    end

    # POST /api/work_order_items
    def create
      if @work_order.present?
        render json: :conflict, status: :conflict
      else
        @work_order = WorkOrder.new
        @work_order.assign_attributes(@json['data'])
        if !@json['data']['created_by']
          @work_order.created_by = current_user.id if !current_user.nil?
        end
        if @work_order.save
          render json: serialized_work_order(@work_order), status: :created
        else
           render json: format_errors(@work_order), status: :unprocessable_entity
        end
      end
    end

    # PUT /api/work_order_item/:id
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
      # work_order = WorkOrder.find(params[:id])
      # work_order.updated_by = current_user.id if !current_user.nil?
      # if work_order.update_attributes(params[:work_order])
      #   render json: serialized_work_order(work_order), status: :ok
      # else
      #   render json: format_errors(work_order), status: :unprocessable_entity
      # end
    end

    # DELETE /api/work_order_item/:id
    def destroy
      if @work_order.destroy
        #head :no_content
        render json: :deleted, status: :ok
      else
        render json: format_errors(@work_order), status: :unprocessable_entity
      end
    end

    private

    # Returns searched WorkOrder
    def find_work_order
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        @work_order = WorkOrder.find(params[:id]) rescue nil
        render json: :not_found, status: :not_found unless @work_order.present?
      end
    end

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
  end
end
