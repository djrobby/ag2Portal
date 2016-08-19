module Ag2Tech
  class Api::V1::WorkOrderStatusesSerializer < ::Api::V1::BaseSerializer
    attributes :id, :name,
                    :created_at, :created_by, :updated_at, :updated_by
  end
end
