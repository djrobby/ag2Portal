class StoreOffice < ActiveRecord::Base
  belongs_to :store
  belongs_to :office
  attr_accessible :store_id, :office_id

  has_paper_trail

  validates :office,  :presence => true
end
