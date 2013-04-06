class ContractType < ActiveRecord::Base
  attr_accessible :ct_code, :name

  validates :ct_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  
  has_many :workers
  def fields_to_uppercase
    self[:ct_code].upcase!
  end

  def to_label
    "#{name} (#{ct_code})"
  end
end
