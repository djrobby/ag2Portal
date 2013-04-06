class DegreeType < ActiveRecord::Base
  attr_accessible :dt_code, :name

  validates :dt_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  has_many :workers
end
