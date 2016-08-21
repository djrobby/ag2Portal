require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class Api::V1::ProjectsController < ::Api::V1::BaseController
    # ag2Tech API
    # returns JSON
    # scope => /ag2_tech
    # URL parameters => <auth>: necessary
    #               user_email=...
    #               user_token=...
    # REST parameters => (<param>): optional
    #               type_id: type id
    #               office_id: office id
    #               id: project id
    #
    # General:
    # GET /api/v1/projects/<method>[/<param>]?<auth>
    #
    # GET /api/v1/projects => all
    # GET /api/v1/projects/:id => one
    # GET /api/v1/projects/by_type/:type_id => by_type
    # GET /api/v1/projects/by_office/:office_id => by_office

    # GET /api/projects
    def all
      projects = Project.by_code
      render json: serialized_projects(projects)
    end

    # GET /api/projects/:id
    def one
      if !is_numeric?(params[:id]) || params[:id] == '0'
        render json: :bad_request, status: :bad_request
      else
        project = Project.find(params[:id]) rescue nil
        if !project.blank?
          render json: Api::V1::ProjectsSerializer.new(project)
        else
          render json: :not_found, status: :not_found
        end
      end
    end

    # GET /api/projects/by_type/:type_id
    def by_type
      if params.has_key?(:type_id) && is_numeric?(params[:type_id]) && params[:type_id] != '0'
        projects = Project.belongs_to_type(params[:type_id])
        if !projects.blank?
          render json: serialized_projects(projects)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    # GET /api/projects/by_office/:office_id
    def by_office
      if params.has_key?(:office_id) && is_numeric?(params[:office_id]) && params[:office_id] != '0'
        projects = Project.belongs_to_office(params[:office_id])
        if !projects.blank?
          render json: serialized_projects(projects)
        else
          render json: :not_found, status: :not_found
        end
      else
        render json: :bad_request, status: :bad_request
      end
    end

    private

    # Returns JSON list of orders
    def serialized_projects(_data)
      ActiveModel::ArraySerializer.new(_data, each_serializer: Api::V1::ProjectsSerializer, root: 'projects')
    end
  end
end
