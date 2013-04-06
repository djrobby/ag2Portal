class WorkerType < ActiveRecord::Base
  attr_accessible :description

  validates :description, :presence => true
  
  has_many :workers
end
