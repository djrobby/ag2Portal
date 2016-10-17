class BillableConcept < ActiveRecord::Base
  # CONSTANTS
  SUPPLY = 1
  CONTRACTING = 2

  attr_accessible :code, :name, :billable_document

  has_many :billable_items

  validates :name, :presence => true
  validates :billable_document, :presence => true
  validates :code, :presence => true,
                   :length => { :is => 3 },
                   :uniqueness => true

  before_validation :fields_to_uppercase

  def to_label
    "#{name} (#{code})"
  end

  def document
    billable_document.to_s == '1' ? I18n.t('activerecord.attributes.billable_concept.supply') : I18n.t('activerecord.attributes.billable_concept.contracting')
  end

  private

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end
end
