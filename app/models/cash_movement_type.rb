class CashMovementType < ActiveRecord::Base
  # CONSTANTS
  INFLOW = 1
  OUTFLOW = 2

  belongs_to :organization
  attr_accessible :code, :name, :type_id, :organization_id

  has_many :cash_movements

  has_paper_trail

  validates :organization,  :presence => true
  validates :name,          :presence => true,
                            :length => { :minimum => 3, :maximum => 40 }
  validates :code,          :presence => true,
                            :length => { :is => 3 },
                            :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => [:organization_id, :type_id] }
  validates :type_id,       :presence => true,
                            :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 2 }
                            # :length => { :is => 1 },
                            # :format => { with: /\A\d+\Z/, message: :type_invalid }

  # Scopes
  scope :by_code, -> { order(:code) }
  # ordered
  scope :belongs_to_organization, -> o { where("organization_id = ?", o).by_code }
  scope :inflows, -> { where(type_id: 1).by_code }
  scope :outflows, -> { where(type_id: 2).by_code }
  scope :inflows_by_organization, -> o { where(type_id: 1, organization_id: o).by_code }
  scope :outflows_by_organization, -> o { where(type_id: 2, organization_id: o).by_code }
  # unordered
  scope :belongs_to_organization_u, -> o { where("organization_id = ?", o) }
  scope :inflows_u, -> { where(type_id: 1) }
  scope :outflows_u, -> { where(type_id: 2) }
  scope :inflows_by_organization_u, -> o { where(type_id: 1, organization_id: o) }
  scope :outflows_by_organization_u, -> o { where(type_id: 2, organization_id: o) }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase

  # Methods
  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = right_code
    if !self.name.blank?
      full_name += " " + self.name
    end
    full_name
  end

  def right_code
    if !code.blank?
      code.rjust(3, ' ')
    else
      id.to_s.rjust(3, '0')
    end
  end

  def right_code_and_type_label
    right_code + '(' + type_label + ')'
  end

  def type_label
    case type_id
      when 1 then I18n.t('activerecord.attributes.cash_movement_type.type_i')
      when 2 then I18n.t('activerecord.attributes.cash_movement_type.type_o')
      else 'N/A'
    end
  end

  def cash_desk_closing_item_type_i
    case type_id
      when 1 then 'C'
      when 2 then 'P'
      else 'N/A'
    end
  end

  private

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  # Before destroy
  def check_for_dependent_records
    # Check for cash movements
    if cash_movements.count > 0
      errors.add(:base, I18n.t('activerecord.models.cash_movement_type.check_for_cash_movements'))
      return false
    end
  end
end
