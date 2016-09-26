module Ag2Tech
  class Api::V1::WorkOrderVehiclesHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :distance, :work_order_id, :vehicle_id,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
