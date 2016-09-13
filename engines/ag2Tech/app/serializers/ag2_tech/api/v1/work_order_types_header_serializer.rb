module Ag2Tech
  class Api::V1::WorkOrderTypesHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :organization_id, :charge_account_id, :work_order_area_id, :subscriber_meter,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
