class Guide < ActiveRecord::Base
  belongs_to :site
  belongs_to :app
  attr_accessible :body, :description, :name, :site_id, :app_id

  validates :name,        :presence => true
  validates :description, :presence => true
  validates :site,        :presence => true
end
