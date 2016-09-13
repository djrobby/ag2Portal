module Ag2Tech
  class Api::V1::WorkOrderItemsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :cost, :description, :price, :quantity,
                    :work_order_id, :product_id, :tax_type_id, :store_id, :charge_account_id,
                    :created_at, :created_by, :updated_at, :updated_by
    has_one :product
    has_one :tax_type
    has_one :store
    has_one :charge_account
  end
end
