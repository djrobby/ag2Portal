class BillingPeriod < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_frequency
  attr_accessible :billing_ending_date, :billing_starting_date, :charging_ending_date, :charging_starting_date,
                  :description, :period, :prebilling_ending_date, :prebilling_starting_date,
                  :reading_ending_date, :reading_starting_date, :billing_frequency_id, :project_id

  has_many :readings
  has_many :pre_readings
  has_many :invoices
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills

  has_paper_trail

  validates :period,            :presence => true,
                                :numericality => true
  validates :billing_frequency, :presence => true

  # Scopes
  scope :by_period, -> { order(:period) }
  #
  scope :belongs_to_project, -> project { where("project_id = ?", project).by_period }
  scope :belongs_to_projects, -> projects { where(project_id: projects).by_period }

  def period_to_date
    year = period.to_s[0..3].to_i
    month = ((period.to_s[4..5].to_i - 1) * (billing_frequency.months || (billing_frequency.days / 30).to_i)) + 1
    Date.new(year,month)
  end

  def previous_period
    date_to_period(period_to_date - time_freq)
  end

  def year_period
    date_to_period(period_to_date - 1.year)
  end

  def previous_billing_period
    BillingPeriod.find_by_period(previous_period)
  end

  def to_label
    "#{period} (#{billing_frequency.try(:name)})"
  end

  private

  def time_freq
    billing_frequency.months == 0 ? billing_frequency.days.days : billing_frequency.months.months
  end

  def month_freq
    billing_frequency.months == 0 ? (billing_frequency.days / 30).to_i : billing_frequency.months
  end

  def date_to_period(date)
    date.strftime("%Y") + format('%02d',(((date.month - 1) / month_freq) + 1))
  end
end
