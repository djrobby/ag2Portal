require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Api::V1::ChargeAccountsController < ::Api::V1::BaseController
    # ag2Tech API
    # returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    # REST parameters => (<param>): optional
    #               project_id: project id
    #               id: charge account id
    #
    # General:
    # GET /api/v1/charge_accounts/<method>[/<param>]?<auth>
    #
    # GET /api/v1/charge_accounts => all
    # GET /api/v1/charge_accounts/:id => one
    # GET /api/v1/charge_accounts/by_project/:project_id => by_project

    # GET /api/charge_accounts
    def all
      charge_accounts = ChargeAccount.expenditures
      render json: serialized_charge_accounts(charge_accounts)
    end

    # GET /api/charge_accounts/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        charge_account = ChargeAccount.find(params[:id]) rescue nil
        if !charge_account.blank?
          render json: Api::V1::ChargeAccountsSerializer.new(charge_account)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/charge_accounts/by_project/:project_id
    def by_project
      if params.has_key?(:project_id) && is_numeric?(params[:project_id]) && params[:project_id] != '0'
        charge_accounts = ChargeAccount.expenditures(params[:project_id])
        if !charge_accounts.blank?
          render json: serialized_charge_accounts(charge_accounts)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    private

    # Returns JSON list of orders
    def serialized_charge_accounts(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::ChargeAccountsSerializer, root: 'charge_accounts')
    end
  end
end
