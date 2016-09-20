module Ag2Tech
  class Api::V1::WorkOrderWorkersSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :hours, :work_order_id, :worker_id, :thing,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :worker
    has_one :charge_account
  end
end
