module Ag2Tech
  class Api::V1::WorkOrderTypesSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name, :organization_id, :charge_account_id, :work_order_area_id, :subscriber_meter,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :organization
    has_one :charge_account
    has_one :work_order_area
  end
end
