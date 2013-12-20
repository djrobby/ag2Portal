class ProfessionalGroup < ActiveRecord::Base
  attr_accessible :name, :pg_code,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :pg_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  
  def fields_to_uppercase
    if !self.pg_code.blank?
      self[:pg_code].upcase!
    end
  end

  def to_label
    "#{name} (#{pg_code})"
  end
end
