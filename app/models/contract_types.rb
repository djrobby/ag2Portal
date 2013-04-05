class ContractTypes < ActiveRecord::Base
  attr_accessible :ct_code, :name

  validates :ct_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  has_many :workers
end
