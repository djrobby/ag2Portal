class Insurance < ActiveRecord::Base
  attr_accessible :name

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :name,  :presence => true
end
