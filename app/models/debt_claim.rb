class DebtClaim < ActiveRecord::Base
  belongs_to :office
  belongs_to :project
  belongs_to :debt_claim_phase
  attr_accessible :claim_no, :closed_at,
                  :office_id, :project_id, :debt_claim_phase_id
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
                                :length => { :is => 13 },
                                :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :office_id }
  validates :office,            :presence => true
  validates :debt_claim_phase,  :presence => true

  # Scopes
  scope :by_no, -> { order(:claim_no) }
  #
  scope :none, where("1 = 0")

  # Callbacks
  before_create :init_phase
  before_save :calculate_and_store_totals

  #
  # Instance methods
  #
  # Formal No

  def full_no
    # Debt claim no (Office & year & sequential number) => OOOO-YYYY-NNNNN
    if claim_no == "$err"
      "0000-0000-00000"
    else
      claim_no.blank? ? "" : claim_no[0.3] + '-' + claim_no[4..7] + '-' + claim_no[8..12]
    end
  end

  def full_no_by_project
    # Debt claim no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    if claim_no == "$err"
      "000000000000-0000-000000"
    else
      claim_no.blank? ? "" : claim_no[0..11] + '-' + claim_no[12..15] + '-' + claim_no[16..21]
    end
  end

  # Short No
  def short_no_by_project
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
    office.company.organization unless (office.blank? || office.company.blank? || office.company.organization.blank?)
  end

  def company
    office.company unless (office.blank? || office.company.blank?)
  end

  def max_status
    debt_claim_items.order(debt_claim_status_id: :desc).first.debt_claim_status rescue nil
  end

  def max_status_name
    max_status.nil? ? '' : max_status.name
  end

  def min_status
    debt_claim_items.order(debt_claim_status_id: :asc).first.debt_claim_status rescue nil
  end

  def min_status_name
    min_status.nil? ? '' : min_status.name
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
  searchable do
    text :claim_no
    date :created_at
    string :claim_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id, :multiple => true
    integer :project_id, :multiple => true
    integer :office_id, :multiple => true
    integer :debt_claim_phase_id
    string :sort_no do
      claim_no
    end
  end

  private

  # Before create
  def init_phase
    self.debt_claim_phase_id = DebtClaimPhase.first.id if debt_claim_phase_id.blank?
  end

  def calculate_and_store_totals
    self.totals = total
  end
end
