module Ag2Tech
  class Api::V1::WorkOrderToolsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :minutes, :work_order_id, :tool_id,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :tool
    has_one :charge_account
  end
end
