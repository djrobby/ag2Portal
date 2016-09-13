module Ag2Tech
  class Api::V1::WorkOrderInfrastructuresHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :infrastructure_type_id, :organization_id,
                    :company_id, :office_id, :code,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
