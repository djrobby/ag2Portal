module Ag2Tech
  class Api::V1::WorkOrderSubcontractorsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :enforcement_pct, :work_order_id, :supplier_id, :purchase_order_id,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :supplier
    has_one :purchase_order
    has_one :charge_account
  end
end
