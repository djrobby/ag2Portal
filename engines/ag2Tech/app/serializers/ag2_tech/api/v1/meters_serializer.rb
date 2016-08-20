module Ag2Tech
  class Api::V1::MetersSerializer < ::Api::V1::BaseSerializer
    attributes :id, :closed_at, :ledger_account_id, :name, :opened_at,
                    :project_id, :account_code, :organization_id, :charge_group_id,
                    :created_at, :created_by, :updated_at, :updated_by

    has_one :project
    has_one :charge_group
    has_one :ledger_account
  end
end
