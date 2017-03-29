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
                  :starting_at, :ending_at, :tariff_ids

  has_one :active_tariff
  has_one :billable_concept, through: :billable_item

  has_many :subscriber_tariffs
  has_many :contracted_tariffs
  has_many :tariff_scheme_items
  has_many :subscribers, through: :subscriber_tariffs

  has_paper_trail

  #validates :tariff_scheme,     :presence => true
  validates :billable_item,     :presence => true
  validates :tariff_type,       :presence => true
  validates :caliber,           :presence => true, :if => :concept_is_sum?
  validates :billing_frequency, :presence => true
  validates :billing_frequency, :presence => true
  validates :starting_at,       :presence => true,
                                :uniqueness => { :scope => [:billable_item_id, :tariff_type_id, :caliber_id, :billing_frequency_id] }
  validates :tax_type_b,        :presence => true, :if => "!block1_fee.blank?"
  validates :tax_type_f,        :presence => true, :if => "!fixed_fee.blank?"
  validates :tax_type_p,        :presence => true, :if => "!percentage_fee.blank?"
  validates :tax_type_v,        :presence => true, :if => "!variable_fee.blank?"

  # tariffs for water supply contract
  # def self.by_contract(water_supply_contract)
  #   where(tariff_scheme_id: water_supply_contract.tariff_scheme.id)
  #   .select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 2}
  #   .select{|t| t.caliber == water_supply_contract.try(:caliber).try(:caliber)}
  #   .group_by{|t| t.try(:billable_item).try(:biller_id)}
  # end

  # Scopes
  scope :belongs_to_project, -> p { joins(:billable_item).where('billable_items.project_id = ?', p) }
  scope :belongs_to_type, -> t { where(tariff_type_id: t) }
  scope :belongs_to_project_type, -> p,t { joins(:billable_item).where('billable_items.project_id = ? AND tariff_type_id = ?', p, t) }
  scope :availables_to_project, -> p { joins(:billable_item).where("billable_items.project_id IN (?) AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", p, Date.today)}
  scope :availables_to_project_type, -> p,t { joins(:billable_item).where("billable_items.project_id = ? AND tariffs.tariff_type_id = ? AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", p, t, Date.today)}
  scope :availables_to_project_type_document, -> p,t,d { joins(:billable_item).joins(:billable_concept).where("billable_items.project_id = ? AND tariffs.tariff_type_id = ? AND billable_concepts.billable_document = ? AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", p, t, d, Date.today)}
  scope :availables_to_project_type_document_caliber, -> p,t,d,c { joins(:billable_item).joins(:billable_concept).order("billable_items.billable_concept_id").where("billable_items.project_id = ? AND tariffs.tariff_type_id = ? AND billable_concepts.billable_document = ? AND (tariffs.caliber_id IS NULL OR tariffs.caliber_id = ? ) AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", p, t, d, c, Date.today)}

  # Callbacks
  before_destroy :check_for_dependent_records
  after_save :assing_ending_at, :reindex_tariff
  after_destroy :reindex_tariff

  searchable do
    integer :id
    integer :project_id do
      billable_item.project_id
    end
    integer :tariff_type_id
    integer :billable_item_id
    integer :caliber_id
    integer :billing_frequency_id
    time :ending_at
    time :starting_at
  end

  def to_label
    "#{tariff_type.name} #{try(:billable_item).try(:billable_concept).try(:name)} - #{caliber.try(:caliber)} (#{I18n.l(starting_at)})"
  end

  # THIS METHOD IS CONCEPTUALLY WRONG!!
  # DO NOT USE!!!
  def tariff_active
    if block1_fee == 0.0 && block2_fee == 0.0 && block3_fee == 0.0 && block4_fee == 0.0 && block5_fee == 0.0 && block6_fee == 0.0 && block7_fee == 0.0 && block8_fee == 0.0 && fixed_fee == 0.0 && variable_fee == 0.0 && percentage_fee == 0.0
      return false
    else
      return true
    end
  end

  # USE THIS METHOD TO CHECK IF IT'S ACTIVE
  def active?
    ending_at.blank?
  end

  def get_code_formula
    if percentage_applicable_formula.blank?
      nil
    else
      BillableConcept.find(percentage_applicable_formula).try(:code)
    end
  end

  def get_code_formula
    if percentage_applicable_formula.blank?
      nil
    else
      BillableConcept.find(percentage_applicable_formula).try(:code)
    end
  end

  #
  # Class (self) user defined methods
  #

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

  def reindex_tariff
    Sunspot.index(self)
  end

  def assing_ending_at
    if !ending_at.blank?
      subscriber_tariffs.update_all(ending_at: ending_at)
      contracted_tariffs.update_all(ending_at: ending_at)
    end
  end

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
