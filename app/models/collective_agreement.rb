class CollectiveAgreement < ActiveRecord::Base
  attr_accessible :ca_code, :name

  validates :ca_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  has_many :workers
end
