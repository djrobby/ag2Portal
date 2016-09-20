module Ag2Tech
  class Api::V1::WorkOrderSubcontractorsHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :enforcement_pct, :work_order_id, :supplier_id, :purchase_order_id, :thing_supplier, :thing_order,
                    :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
