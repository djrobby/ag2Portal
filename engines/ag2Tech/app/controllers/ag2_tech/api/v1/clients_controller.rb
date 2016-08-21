require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Api::V1::ClientsController < ::Api::V1::BaseController
    # ag2Tech API
    # returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    # REST parameters => (<param>): optional
    #               id: client id
    #
    # General:
    # GET /api/v1/clients/<method>[/<param>]?<auth>
    #
    # GET /api/v1/clients => all
    # GET /api/v1/clients/:id => one

    # GET /api/clients
    def all
      clients = Client.by_code
      render json: serialized_clients(clients)
    end

    # GET /api/clients/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        client = Client.find(params[:id]) rescue nil
        if !client.blank?
          render json: Api::V1::ClientsSerializer.new(client)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    private

    # Returns JSON list of orders
    def serialized_clients(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::ClientsSerializer, root: 'clients')
    end
  end
end
