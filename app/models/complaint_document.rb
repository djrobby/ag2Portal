class ComplaintDocument < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :complaint_document_type
  attr_accessible :flow, :attachment, :complaint_id, :complaint_document_type_id
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/attachment.png"

  has_paper_trail

  validates :complaint_document_type_id,  :presence => true
  validates :flow,                        :presence => true,
                                          :numericality => { :only_integer => true, :greater_than => 0, :less_than => 3 }
end
