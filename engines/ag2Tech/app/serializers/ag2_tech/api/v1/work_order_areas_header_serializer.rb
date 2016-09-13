module Ag2Tech
  class Api::V1::WorkOrderAreasHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :organization_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
