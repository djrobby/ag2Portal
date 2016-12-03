class BillableConcept < ActiveRecord::Base
  # CONSTANTS
  SUPPLY = 1
  CONTRACTING = 2

  attr_accessible :code, :name, :billable_document

  has_many :billable_items

  has_paper_trail

  validates :name, :presence => true
  validates :billable_document, :presence => true
  validates :code, :presence => true,
                   :length => { :is => 3 },
                   :uniqueness => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def to_label
    "#{code} #{name}"
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

  def check_for_dependent_records
    # Check for billable items
    if billable_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.billable_concept.check_for_billable_items'))
      return false
    end
  end
end
