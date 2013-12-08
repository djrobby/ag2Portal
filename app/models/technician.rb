class Technician < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :user_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :name, :presence => true
  validates :user, :presence => true

  has_many :tickets
end
