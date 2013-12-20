class CollectiveAgreement < ActiveRecord::Base
  attr_accessible :ca_code, :name, :hours,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :ca_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.ca_code.blank?
      self[:ca_code].upcase!
    end
  end

  def to_label
    "#{name} (#{ca_code})"
  end
end
