module Ag2Tech
  class Api::V1::ProjectsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :closed_at, :ledger_account_id, :name, :opened_at, :project_code,
                    :office_id, :company_id, :organization_id, :project_type_id,
                    :max_order_total, :max_order_price,
                    :created_at, :created_by, :updated_at, :updated_by

    has_one :company
    has_one :office
    has_one :project_type
    has_one :ledger_account
  end
end
