class BillingPeriod < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_frequency
  attr_accessible :billing_ending_date, :billing_starting_date, :charging_ending_date, :charging_starting_date,
                  :description, :period, :prebilling_ending_date, :prebilling_starting_date,
                  :reading_ending_date, :reading_starting_date

  has_many :readings
  has_many :pre_readings

  def period_to_date
    year = period.to_s[0..3].to_i
    month = ((period.to_s[4..5].to_i - 1) * (billing_frequency.months || (billing_frequency.days / 30).to_i)) + 1
    Date.new(year,month)
  end

  def date_to_period(date)
    date.strftime("%Y") + format('%02d',(((date.month - 1) / billing_frequency.months) + 1))
  end

  def previous_period
    date_to_period(period_to_date - (billing_frequency.months.months || billing_frequency.days.days))
  end

  def year_period
    date_to_period(period_to_date - 1.year)
  end

  def previous_billing_period
    BillingPeriod.find_by_period(previous_period)
  end

  def to_label
    "#{period}"
  end
end
