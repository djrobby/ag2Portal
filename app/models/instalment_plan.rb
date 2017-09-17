class InstalmentPlan < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :client
  belongs_to :subscriber
  belongs_to :organization
  attr_accessible :instalment_date, :instalment_no, :surcharge_pct,
                  :payment_method_id, :client_id, :subscriber_id, :organization_id,
                  :created_by, :updated_by

  has_many :instalments, dependent: :destroy
  has_many :instalment_invoices, through: :instalments

  has_paper_trail

  validates :instalment_no,   :presence => true,
                              :length => { :is => 22 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :instalment_date, :presence => true
  validates :payment_method,  :presence => true
  validates :client,          :presence => true
  validates :organization,    :presence => true

  # Scopes
  scope :by_no, -> { order(:instalment_no) }
  #
  scope :belongs_to_project, -> project { where("project_id = ?", project).by_code }

  def full_no
    # Instalment no (Client code & year & sequential number) => CCCCCCCCCCC-YYYY-NNNNNNN
    if instalment_no == "$err"
      "00000000000-0000-0000000"
    else
      instalment_no.blank? ? "" : instalment_no[0..10] + '-' + instalment_no[11..14] + '-' + instalment_no[15..21]
    end
  end

  #
  # Calculated fields
  #
  def instalments_qty
    instalments.count
  end

  def subtotal
    instalments.sum(:amount)
  end

  def surcharges
    instalments.sum(:surcharge)
  end

  def total
    subtotal + surcharges
  end

  def amount_collected
    instalments.sum(&:amount_collected)
  end

  def surcharge_collected
    instalments.sum(&:surcharge_collected)
  end

  def collected
    amount_collected + surcharge_collected
  end

  def debt
    total - collected
  end
end
