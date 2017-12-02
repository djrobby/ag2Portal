class ContractingRequestDocumentType < ActiveRecord::Base
  attr_accessible :name, :required

  has_many :contracting_request_documents

  has_paper_trail

  validates :name,  :presence => true

  before_validation :fields_to_uppercase

  def to_label
    "#{name}"
  end

  def to_label_required
    required.blank? ? "#{name}" : "#{name} *"
  end
  
  def fields_to_uppercase
    if !self.name.blank?
      self[:name].replace(self[:name].mb_chars.upcase!.to_s)
    end
  end
end
