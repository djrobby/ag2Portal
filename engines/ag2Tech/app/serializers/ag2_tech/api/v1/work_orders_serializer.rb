module Ag2Tech
  class Api::V1::WorkOrdersSerializer < ::Api::V1::BaseSerializer
    attributes :id, :closed_at, :completed_at, :order_no, :started_at,
                    :work_order_labor_id, :work_order_status_id, :work_order_type_id, :work_order_area_id,
                    :charge_account_id, :project_id, :area_id, :store_id, :client_id, :infrastructure_id,
                    :remarks, :description, :petitioner, :master_order_id, :organization_id,
                    :in_charge_id, :reported_at, :approved_at, :certified_at, :posted_at,
                    :location, :pub_record, :subscriber_id, :incidences, :por_affected,
                    :meter_id, :meter_code, :meter_model_id, :caliber_id, :meter_owner_id,
                    :meter_location_id, :last_reading_id, :current_reading_date, :current_reading_index, :hours_type,
                    :created_at, :created_by, :updated_at, :updated_by

    has_many :work_order_items
    has_many :work_order_workers
    has_many :work_order_tools
    has_many :work_order_vehicles
    has_many :work_order_subcontractors

    has_one :work_order_area
    has_one :work_order_type
    has_one :work_order_status
    has_one :work_order_labor
    has_one :project
  end
end
