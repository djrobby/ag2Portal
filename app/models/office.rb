class Office < ActiveRecord::Base
  belongs_to :company

  attr_accessible :name, :company_id, :office_code

  validates :name,  :presence => true
  validates :company_id,  :presence => true
  validates :office_code,  :presence => true
end
