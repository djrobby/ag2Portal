class Department < ActiveRecord::Base
  attr_accessible :name

  validates :name,  :presence => true

  has_many :workers
  has_many :corp_contacts
  def to_label
    "#{name}"
  end
end
