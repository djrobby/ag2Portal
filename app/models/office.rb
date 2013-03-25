class Office < ActiveRecord::Base
  belongs_to :company

  attr_accessible :name, :company_id

  validates :name,  :presence => true
  validates :company_id,  :presence => true
end
