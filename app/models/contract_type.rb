class ContractType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :ct_code, :name, :organization_id,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :ct_code,       :presence => true,
                            :length => { :minimum => 2 },
                            :uniqueness => { :scope => :organization_id }
  validates :name,          :presence => true
  validates :organization,  :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  
  def fields_to_uppercase
    if !self.ct_code.blank?
      self[:ct_code].upcase!
    end
  end

  def to_label
    "#{name} (#{ct_code})"
  end

  private

  def check_for_dependent_records
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_type.check_for_workers'))
      return false
    end
  end
end
