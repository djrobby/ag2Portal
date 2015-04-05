class RatioGroup < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :code, :name, :organization_id
  has_many :ratios
end
