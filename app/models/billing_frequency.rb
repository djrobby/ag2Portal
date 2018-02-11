# encoding: utf-8

class BillingFrequency < ActiveRecord::Base
  belongs_to :fix_measure, class_name: 'Measure'
  belongs_to :var_measure, class_name: 'Measure'
  attr_accessible :days, :months, :name,
                  :fix_measure_id, :var_measure_id

  validates :name,    :presence => true
  validates :months,  :numericality => true, length: { maximum: 2 }
  validates :days,    :numericality => true, length: { maximum: 2 }

  validate :days_xor_months

  has_paper_trail

  def total_months
    months.nil? || months.zero? ? (days / 30.436875).round : months
  end

  def to_label
    if days.zero?
      return name + " - " + months.to_s + ' mes/es'
    else
      return name + " - " + days.to_s + ' día/s'
    end
  end

  private

  def days_xor_months
    if !(days? ^ months?)
      errors[:days] << "Especifica días o meses, no ambos"
    end
  end
end
