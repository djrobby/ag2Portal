class TimeRecord < ActiveRecord::Base
  belongs_to :worker
  belongs_to :timerecord_type
  belongs_to :timerecord_code
  attr_accessible :timerecord_date, :timerecord_time, :worker_id,
                  :timerecord_type_id, :timerecord_code_id,
                  :created_by, :updated_by, :source_ip

  has_paper_trail

  validates :timerecord_date,  :presence => true
  validates :timerecord_time,  :presence => true
  validates :timerecord_type,  :presence => true
  validates :timerecord_code,  :presence => true
  validates :worker,           :presence => true

  searchable do
    integer :worker_id
    integer :timerecord_type_id
    integer :timerecord_code_id
    date :timerecord_date
    time :timerecord_time
  end
end
