class Tariff < ActiveRecord::Base
  #belongs_to :tariff_scheme
  belongs_to :billable_item
  belongs_to :tariff_type
  belongs_to :caliber
  belongs_to :billing_frequency
  belongs_to :tax_type_b, class_name: "TaxType"
  belongs_to :tax_type_f, class_name: "TaxType"
  belongs_to :tax_type_p, class_name: "TaxType"
  belongs_to :tax_type_v, class_name: "TaxType"
  has_many :invoice_items
  attr_accessible :block1_fee, :block1_limit, :block2_fee, :block2_limit, :block3_fee,
                  :block3_limit, :block4_fee, :block4_limit, :block5_fee, :block5_limit,
                  :block6_fee, :block6_limit, :block7_fee, :block7_limit, :block8_fee,
                  :block8_limit, :discount_pct_b, :discount_pct_f, :discount_pct_p, :discount_pct_v,
                  :fixed_fee, :percentage_applicable_formula, :percentage_fee, :tax_type_b_id,
                  :tax_type_f_id, :tax_type_p_id, :tax_type_v_id, :variable_fee, :tariff_type_id,
                  :billable_item_id, :caliber_id, :tariff_scheme_id, :billing_frequency_id,
                  :starting_at, :ending_at

  has_many :subscriber_tariffs
  has_many :contracted_tariffs
  has_many :tariff_scheme_items

  #validates :tariff_scheme,     :presence => true
  validates :billable_item,     :presence => true
  validates :tariff_type,       :presence => true
  validates :caliber,           :presence => true, :if => :concept_is_sum?
  validates :billing_frequency, :presence => true
  validates :billing_frequency, :presence => true
  #validates :starting_at,       :presence => true
  #validates :tariff_scheme_id, uniqueness: {scope: [:billable_item_id, :tariff_type_id, :caliber_id, :billing_frequency_id]}

  # tariffs for water supply contract
  # def self.by_contract(water_supply_contract)
  #   where(tariff_scheme_id: water_supply_contract.tariff_scheme.id)
  #   .select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 2}
  #   .select{|t| t.caliber == water_supply_contract.try(:caliber).try(:caliber)}
  #   .group_by{|t| t.try(:billable_item).try(:biller_id)}
  # end

  # Scopes

  before_destroy :check_for_dependent_records

  def tariff_active
    if block1_fee == 0.0 && block2_fee == 0.0 && block3_fee == 0.0 && block4_fee == 0.0 && block5_fee == 0.0 && block6_fee == 0.0 && block7_fee == 0.0 && block8_fee == 0.0 && fixed_fee == 0.0 && variable_fee == 0.0 && percentage_fee == 0.0
      return false
    else
      return true
    end
  end

  #
  # Records navigator
  #
  def to_first
    Tariff.order("id").first
  end

  def to_prev
    Tariff.where("id < ?", id).order("id").last
  end

  def to_next
    Tariff.where("id > ?", id).order("id").first
  end

  def to_last
    Tariff.order("id").last
  end

  private

  def concept_is_sum?
    billable_item and billable_item.billable_concept.code == "SUM"
  end

  # Before destroy
  def check_for_dependent_records
    # Check for subscriber tariffs
    if subscriber_tariffs.count > 0
      errors.add(:base, I18n.t('activerecord.models.tariff.check_for_subscriber_tariffs'))
      return false
    end
    # Check for contracted tariffs
    if contracted_tariffs.count > 0
      errors.add(:base, I18n.t('activerecord.models.tariff.check_for_contracted_tariffs'))
      return false
    end
    # Check for tariff scheme items
    if tariff_scheme_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tariff.check_for_tariff_scheme_items'))
      return false
    end
  end
end
