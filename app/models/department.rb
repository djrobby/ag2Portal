class Department < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company
  belongs_to :worker
  attr_accessible :name, :code, :organization_id, :company_id, :worker_id,
                  :created_by, :updated_by

  has_many :areas
  has_many :workers
  has_many :worker_items
  has_many :corp_contacts

  has_paper_trail

  validates :name,          :presence => true
  validates :code,          :presence => true,
                            :length => { :in => 3..9 },
                            :uniqueness => { :scope => :organization_id }
  validates :organization,  :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{name} (#{code})"
  end

  def name_and_company
    _nac = self.name
    _nac += " (" + self.company.name[0,40].strip + ")" if !self.company.blank?
    _nac
  end

  private

  def check_for_dependent_records
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.department.check_for_workers'))
      return false
    end
    # Check for areas
    if areas.count > 0
      errors.add(:base, I18n.t('activerecord.models.department.check_for_areas'))
      return false
    end
  end
end
