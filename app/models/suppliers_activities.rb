class SuppliersActivities < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :activity
  attr_accessible :default, :supplier_id, :activity_id

  validates_uniqueness_of :supplier_id, :scope => [:activity_id]
end
