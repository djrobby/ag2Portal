class ContractType < ActiveRecord::Base
  attr_accessible :ct_code, :name,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :ct_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  
  def fields_to_uppercase
    if !self.ct_code.blank?
      self[:ct_code].upcase!
    end
  end

  def to_label
    "#{name} (#{ct_code})"
  end
end
