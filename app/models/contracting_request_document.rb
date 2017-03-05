class ContractingRequestDocument < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :contracting_request_document_type

  attr_accessible :contracting_request_document_type_id, :contracting_request_id, :attachment

  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/attachment.png"

  has_paper_trail

  validates :attachment, :contracting_request_document_type_id, :presence => true
end
