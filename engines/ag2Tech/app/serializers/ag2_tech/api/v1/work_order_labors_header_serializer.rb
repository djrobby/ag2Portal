module Ag2Tech
  class Api::V1::WorkOrderLaborsHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :organization_id, :work_order_type_id, :subscriber_meter,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
