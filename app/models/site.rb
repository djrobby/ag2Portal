class Site < ActiveRecord::Base
  attr_accessible :description, :icon_file, :name, :path, :pict_file,
                  :created_by, :updated_by

  validates :description, :presence => true
  validates :icon_file,   :presence => true
  validates :name,        :presence => true
  validates :path,        :presence => true
  validates :pict_file,   :presence => true

  has_paper_trail

  has_many :apps
end
