module Ag2Tech
  class Api::V1::WorkOrderToolsHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :minutes, :work_order_id, :tool_id,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
