class TimeRecord < ActiveRecord::Base
  belongs_to :worker
  belongs_to :timerecord_type
  belongs_to :timerecord_code
  attr_accessible :timerecord_date, :timerecord_time, :worker_id,
                  :timerecord_type_id, :timerecord_code_id
end
