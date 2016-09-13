module Ag2Tech
  class Api::V1::WorkOrderItemsHeaderSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :description, :price, :quantity,
                    :work_order_id, :product_id, :tax_type_id, :store_id, :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
