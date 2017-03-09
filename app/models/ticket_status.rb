class TicketStatus < ActiveRecord::Base
  # CONSTANTS
  UNASSIGNED = 1
  IN_PROGRESS = 2
  ON_HOLD = 3
  RESOLVED = 4

  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :name,  :presence => true

  has_many :tickets
end
