class DebtClaim < ActiveRecord::Base
  belongs_to :project
  belongs_to :debt_claim_phase
  attr_accessible :claim_no, :closed_at,
                  :project_id, :debt_claim_phase_id
  attr_accessible :debt_claim_items_attributes

  has_many :debt_claim_items, dependent: :destroy

  has_paper_trail

  # Nested attributes
  accepts_nested_attributes_for :debt_claim_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  # Validations
  validates_associated :debt_claim_items

  validates :claim_no,          :presence => true,
                                :length => { :is => 22 },
                                :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :project_id }
  validates :project,           :presence => true
  validates :debt_claim_phase,  :presence => true

  # Scopes

  # Callbacks
  before_create :init_phase
  before_save :calculate_and_store_totals

  #
  # Instance methods
  #
  # Formal No
  def full_no
    # Debt claim no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    if claim_no == "$err"
      "000000000000-0000-000000"
    else
      claim_no.blank? ? "" : claim_no[0..11] + '-' + claim_no[12..15] + '-' + claim_no[16..21]
    end
  end

  # Short No
  def short_no
    # Debt claim no (Project ID & year & sequential number) => PPPP-YYYY-NNNNNN
    code = "0000-0000-000000"
    if claim_no != "$err" && !claim_no.blank? && !project_id.blank?
      code = project_id.to_s.rjust(4, '0') + '-' + claim_no[12..15] + '-' + claim_no[16..21]
    end
    code
  end

  def surcharge_pct
    (debt_claim_phase.blank? || debt_claim_phase.surcharge_pct.blank?) ? 0 : debt_claim_phase.surcharge_pct
  end

  def organization
    project.organization unless (project.blank? || project.organization.blank?)
  end

  def company
    project.company unless (project.blank? || project.company.blank?)
  end

  def office
    project.office unless (project.blank? || project.office.blank?)
  end

  #
  # Calculated fields
  #
  def subtotal
    debt_claim_items.reject(&:marked_for_destruction?).sum(&:debt)
  end

  def surcharges
    subtotal * surcharge_pct
  end

  def total
    subtotal + surcharges
  end

  def current_subtotal
    debt_claim_items.reject(&:marked_for_destruction?).sum(&:current_debt)
  end

  def current_total
    current_subtotal + surcharge
  end

  #
  # Class (self) user defined methods
  #

  #
  # Search
  #

  private

  # Before create
  def init_phase
    self.debt_claim_phase_id = DebtClaimPhase.first.id if debt_claim_phase_id.blank?
  end

  def calculate_and_store_totals
    self.totals = total
  end
end
