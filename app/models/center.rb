class Center < ActiveRecord::Base
  belongs_to :town
  attr_accessible :active, :name

  validates :town,        :presence => true
  validates :name,        :presence => true
end
