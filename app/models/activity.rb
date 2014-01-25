class Activity < ActiveRecord::Base
  has_and_belongs_to_many :suppliers, :join_table => :suppliers_activities
  attr_accessible :description

  has_paper_trail

  validates :description, :presence => true
  def to_label
    "#{description}"
  end
end
