class TicketPriority < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  validates :name,  :presence => true

  has_many :tickets
end
