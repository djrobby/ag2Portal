class ActiveTariff < ActiveRecord::Base
  include ModelsModule

  belongs_to :tariff

  attr_accessible :tariff_id, :project_id, :project_code, :tariff_type_id, :tariff_type_code, :billable_concept_id,
                  :billable_concept_code, :caliber_id, :caliber, :billing_frequency_id, :billing_frequency_name,
                  :starting_at, :fixed_fee, :variable_fee, :percentage_fee,
                  :block1_fee, :block2_fee, :block3_fee, :block4_fee, :block5_fee, :block6_fee, :block7_fee, :block8_fee
  # Scopes
  scope :belongs_to_project, -> p { where(project_id: p) }
  scope :belongs_to_type, -> t { where(tariff_type_id: t) }
  scope :belongs_to_project_type, -> p,t { where(project_id: p, tariff_type_id: t) }

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
