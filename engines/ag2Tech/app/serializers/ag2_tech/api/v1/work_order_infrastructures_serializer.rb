module Ag2Tech
  class Api::V1::WorkOrderInfrastructuresSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :infrastructure_type_id, :organization_id,
                    :company_id, :office_id, :code,
                    :created_at, :created_by, :updated_at, :updated_by

    has_one :company
    has_one :office
    has_one :infrastructure_type
  end
end
