class ProfessionalGroup < ActiveRecord::Base
  attr_accessible :name, :pg_code

  validates :pg_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  has_many :workers
end
