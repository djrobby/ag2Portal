class Site < ActiveRecord::Base
  attr_accessible :description, :icon_file, :name, :path, :pict_file

  validates :description, :presence => true
  validates :icon_file,   :presence => true
  validates :name,        :presence => true
  validates :path,        :presence => true
  validates :pict_file,   :presence => true

  has_many :apps
end
