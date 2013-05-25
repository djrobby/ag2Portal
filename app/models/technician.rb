class Technician < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :user_id,
                  :created_by, :updated_by

  validates :name,    :presence => true
  validates :user_id, :presence => true

  has_many :tickets
end
