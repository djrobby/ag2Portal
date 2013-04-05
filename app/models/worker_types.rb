class WorkerTypes < ActiveRecord::Base
  attr_accessible :description
  
  has_many :workers
end
