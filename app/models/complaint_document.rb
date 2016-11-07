class ComplaintDocument < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :complaint_document_type
  attr_accessible :flow
end
