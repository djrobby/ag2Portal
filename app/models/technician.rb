class Technician < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  attr_accessible :name, :user_id,
                  :created_by, :updated_by, :organization_id

  has_paper_trail

  validates :name,          :presence => true
  validates :user,          :presence => true,
                            :uniqueness => { :scope => :organization_id }
  validates :organization,  :presence => true

  has_many :tickets
end
