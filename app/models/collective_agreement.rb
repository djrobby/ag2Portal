class CollectiveAgreement < ActiveRecord::Base
  attr_accessible :ca_code, :name, :hours,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :ca_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.ca_code.blank?
      self[:ca_code].upcase!
    end
  end

  def to_label
    "#{name} (#{ca_code})"
  end

  private

  def check_for_dependent_records
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.collective_agreement.check_for_workers'))
      return false
    end
  end
end
