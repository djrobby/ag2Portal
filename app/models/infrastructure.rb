class Infrastructure < ActiveRecord::Base
  belongs_to :infrastructure_type
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  attr_accessible :name, :infrastructure_type_id, :organization_id,
                  :company_id, :office_id, :code

  has_many :work_orders

  has_paper_trail

  validates :code,                :presence => true,
                                  :length => { :minimum => 3, :maximum => 12 },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                  :uniqueness => { :scope => :organization_id }
  validates :name,                :presence => true
  validates :infrastructure_type, :presence => true
  validates :organization,        :presence => true

  # Scopes
  scope :by_code, -> { order(:code) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_code }
  scope :belongs_to_company, -> company { where("company_id = ?", company).by_code }
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_code }
  scope :belongs_to_type, -> type { where("infrastructure_type_id = ?", type).by_code }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Infrastructure code (Organization id & infrastructure type id & sequential number) => OOO-TTT-NNNNNN
    code.blank? ? "" : code[0..2] + '-' + code[3..5] + '-' + code[6..11]
  end

  searchable do
    text :code, :name
    string :code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :company_id
    integer :office_id
    integer :organization_id
    string :sort_no do
      code
    end
  end

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.infrastructure.check_for_work_orders'))
      return false
    end
  end
end
