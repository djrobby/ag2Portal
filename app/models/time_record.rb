class TimeRecord < ActiveRecord::Base
  belongs_to :worker
  belongs_to :timerecord_type
  belongs_to :timerecord_code
  attr_accessible :timerecord_date, :timerecord_time, :worker_id,
                  :timerecord_type_id, :timerecord_code_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :timerecord_date,     :presence => true
  validates :timerecord_time,     :presence => true
  validates :timerecord_type_id,  :presence => true
  validates :timerecord_code_id,  :presence => true
  validates :worker_id,           :presence => true

  searchable do
    integer :worker_id
    integer :timerecord_type_id
    integer :timerecord_code_id
    date :timerecord_date
    time :timerecord_time
  end
end
