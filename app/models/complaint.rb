class Complaint < ActiveRecord::Base
  belongs_to :complaint_class
  belongs_to :complaint_status
  belongs_to :client
  belongs_to :subscriber
  belongs_to :project
  attr_accessible :answer, :complaint_no, :description, :ending_at, :official_sheet, :remarks, :starting_at
end
