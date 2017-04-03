class ActiveTariff < ActiveRecord::Base
  include ModelsModule

  belongs_to :tariff
  belongs_to :billable_item
  belongs_to :tax_type_b, class_name: "TaxType"
  belongs_to :tax_type_f, class_name: "TaxType"
  belongs_to :tax_type_p, class_name: "TaxType"
  belongs_to :tax_type_v, class_name: "TaxType"

  attr_accessible :tariff_id, :billable_item_id, :project_id, :project_code, :tariff_type_id, :tariff_type_code, :billable_concept_id,
                  :billable_concept_code, :caliber_id, :caliber, :billing_frequency_id, :billing_frequency_name,
                  :starting_at, :fixed_fee, :variable_fee, :percentage_fee,
                  :block1_limit, :block2_limit, :block3_limit, :block4_limit, :block5_limit, :block6_limit, :block7_limit, :block8_limit,
                  :block1_fee, :block2_fee, :block3_fee, :block4_fee, :block5_fee, :block6_fee, :block7_fee, :block8_fee,
                  :discount_pct_b, :discount_pct_f, :discount_pct_p, :discount_pct_v,
                  :tax_type_b_id,:tax_type_f_id, :tax_type_p_id, :tax_type_v_id, :percentage_fixed_fee
  # Scopes
  scope :belongs_to_project, -> p { where(project_id: p) }
  scope :belongs_to_type, -> t { where(tariff_type_id: t) }
  scope :belongs_to_caliber, -> c { where(caliber_id: c) }
  scope :belongs_to_concept, -> bc { where(billable_concept_id: bc) }
  scope :belongs_to_project_type, -> p,t { where(project_id: p, tariff_type_id: t) }
  scope :belongs_to_project_caliber, -> p,c { where(project_id: p, caliber_id: c) }
  scope :belongs_to_project_concept, -> p,bc { where(project_id: p, billable_concept_id: bc) }
  scope :belongs_to_project_type_caliber, -> p,t,c { where(project_id: p, tariff_type_id: t, caliber_id: c) }
  scope :belongs_to_project_type_concept, -> p,t,bc { where(project_id: p, tariff_type_id: t, billable_concept_id: bc) }
  scope :belongs_to_project_caliber_concept, -> p,c,bc { where(project_id: p, caliber_id: c, billable_concept_id: bc) }
  scope :belongs_to_project_type_caliber_concept, -> p,t,c,bc { where(project_id: p, tariff_type_id: t, caliber_id: c, billable_concept_id: bc) }

  def to_label
    "#{dropdowns}"
  end

  def dropdowns
    dd = ""
    if !self.project_code.blank?
      dd += self.full_project_code
    end
    if !self.tariff_type_code.blank?
      dd += " " + self.tariff_type_code
    end
    if !self.billable_concept_code.blank?
      dd += " " + self.billable_concept_code
    end
    if !self.caliber.blank?
      dd += " " + self.caliber.to_s
    end
    if !self.billing_frequency_name.blank?
      dd += " " + self.billing_frequency_name
    end
    if !self.starting_at.blank?
      dd += " " + formatted_date(self.starting_at)
    end
    dd
  end

  def full_project_code
    # Project code (Company id & project type code & sequential number) => CCC-TTT-NNNNNN
    project_code.blank? ? "" : project_code[0..2] + '-' + project_code[3..5] + '-' + project_code[6..11]
  end
end
