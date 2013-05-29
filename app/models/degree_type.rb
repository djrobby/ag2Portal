class DegreeType < ActiveRecord::Base
  attr_accessible :dt_code, :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :dt_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  before_validation :fields_to_uppercase

  has_many :workers
  def fields_to_uppercase
    self[:dt_code].upcase!
  end

  def to_label
    "#{name} (#{dt_code})"
  end
end
