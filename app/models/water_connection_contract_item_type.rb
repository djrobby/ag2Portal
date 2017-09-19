class WaterConnectionContractItemType < ActiveRecord::Base
  attr_accessible :description, :price, :flow

  has_many :water_connection_contract_items

  has_paper_trail

  validates :description,  :presence => true
  validates :flow,  :presence => true

  def to_label
    "#{description}"
  end

end