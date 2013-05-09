class CollectiveAgreement < ActiveRecord::Base
  attr_accessible :ca_code, :name,
                  :created_by, :updated_by

  validates :ca_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase

  has_many :workers
  def fields_to_uppercase
    self[:ca_code].upcase!
  end

  def to_label
    "#{name} (#{ca_code})"
  end
end
