class StoreOffice < ActiveRecord::Base
  belongs_to :store
  belongs_to :office
  attr_accessor :thing
  attr_accessible :store_id, :office_id, :thing

  has_paper_trail

  validates :office,  :presence => true
end
