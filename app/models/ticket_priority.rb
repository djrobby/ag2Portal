class TicketPriority < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :name,  :presence => true

  has_many :tickets
  
  scope :user_only, -> { where('id < ?', 3).order('id') }
end
