module Ag2Tech
  class Api::V1::WorkOrderLaborsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :organization_id, :work_order_type_id, :subscriber_meter,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :organization
    has_one :work_order_type
  end
end
