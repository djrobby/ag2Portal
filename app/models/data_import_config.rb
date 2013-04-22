class DataImportConfig < ActiveRecord::Base
  attr_accessible :name, :source, :target

  validates :name,    :presence => true,
                      :uniqueness => true
  validates :source,  :presence => true
  validates :target,  :presence => true
end
