class Ratio < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ratio_group
  attr_accessible :code, :formula, :name, :organization_id, :ratio_group_id
end
