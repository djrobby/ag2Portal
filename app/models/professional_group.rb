class ProfessionalGroup < ActiveRecord::Base
  attr_accessible :name, :pg_code,
                  :created_by, :updated_by

  has_paper_trail

  validates :pg_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  
  has_many :workers
  def fields_to_uppercase
    self[:pg_code].upcase!
  end

  def to_label
    "#{name} (#{pg_code})"
  end
end
