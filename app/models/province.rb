class Province < ActiveRecord::Base
  attr_accessible :ine_cpro, :name

  validates :name,  :presence => true
  validates :ine_cpro, :presence => true,
                       :length => { :minimum => 2 }
                       
  has_many :towns
end
