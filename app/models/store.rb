class Store < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  attr_accessible :location, :name, :company_id, :office_id

  has_paper_trail

  validates :name,       :presence => true
  validates :company_id, :presence => true
end
