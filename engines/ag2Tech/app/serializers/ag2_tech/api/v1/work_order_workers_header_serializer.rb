module Ag2Tech
  class Api::V1::WorkOrderWorkersHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :hours, :work_order_id, :worker_id, :thing,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
