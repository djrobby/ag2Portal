class ComplaintDocumentType < ActiveRecord::Base
  attr_accessible :name

  has_many :complaint_documents

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for complaint_documents
    if complaint_documents.count > 0
      errors.add(:base, I18n.t('activerecord.models.complaint_document_type.check_for_complaint_documents'))
      return false
    end
  end
end
