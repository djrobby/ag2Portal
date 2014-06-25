class Subguide < ActiveRecord::Base
  belongs_to :guide
  attr_accessible :body, :description, :name, :sort_order, :guide_id

  has_paper_trail

  validates :name,        :presence => true
  validates :description, :presence => true
  validates :guide,       :presence => true
  validates :sort_order,  :presence => true
end
