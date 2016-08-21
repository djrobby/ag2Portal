require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Api::V1::StoresController < ::Api::V1::BaseController
    # ag2Tech API
    # returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    # REST parameters => (<param>): optional
    #               office_id: office id
    #               id: store id
    #
    # General:
    # GET /api/v1/stores/<method>[/<param>]?<auth>
    #
    # GET /api/v1/stores => all
    # GET /api/v1/stores/:id => one
    # GET /api/v1/stores/by_office/:office_id => by_office

    # GET /api/stores
    def all
      stores = Store.by_name
      render json: serialized_stores(stores)
    end

    # GET /api/stores/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        store = Store.find(params[:id]) rescue nil
        if !store.blank?
          render json: Api::V1::StoresSerializer.new(store)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/stores/by_office/:office_id
    def by_office
      if params.has_key?(:office_id) && is_numeric?(params[:office_id]) && params[:office_id] != '0'
        stores = Store.belongs_to_office(params[:office_id])
        if !stores.blank?
          render json: serialized_stores(stores)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    private

    # Returns JSON list of orders
    def serialized_stores(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::StoresSerializer, root: 'stores')
    end
  end
end
