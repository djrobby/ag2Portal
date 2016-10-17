class BillingFrequency < ActiveRecord::Base
  belongs_to :fix_measure, class_name: 'Measure'
  belongs_to :var_measure, class_name: 'Measure'
  attr_accessible :days, :months, :name,
                  :fix_measure_id, :var_measure_id

  validates :name,    :presence => true
  validates :months,  :numericality => true, length: { maximum: 2 }
  validates :days,    :numericality => true, length: { maximum: 2 }

  validate :days_xor_months

  def total_months
    months.nil? ? days / 30 : months 
  end

  def to_label
    if days.zero?
      return months.to_s + (months==1 ? ' mes' : ' meses')
    else
      return days.to_s + (days==1 ? ' dia' : ' dias')
    end
  end

  private

  def days_xor_months
    if !(days? ^ months?)
      errors[:days] << "Espcifica dias o meses, no ambos"
    end
  end
end
