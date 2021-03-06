# encoding: utf-8

class Tariff < ActiveRecord::Base
  # CONSTANTS
  # increment_apply_to
  NONE = 0
  FIXED = 1
  VARIABLE = 2
  BOTH = 3
  APPLY_TO = { I18n.t('activerecord.attributes.tariff.NONE') => 0, I18n.t('activerecord.attributes.tariff.FIXED') => 1, I18n.t('activerecord.attributes.tariff.VARIABLE') => 2, I18n.t('activerecord.attributes.tariff.BOTH') => 3 }

  #belongs_to :tariff_scheme
  belongs_to :billable_item
  belongs_to :tariff_type
  belongs_to :caliber
  belongs_to :billing_frequency
  belongs_to :tax_type_b, class_name: "TaxType"
  belongs_to :tax_type_f, class_name: "TaxType"
  belongs_to :tax_type_p, class_name: "TaxType"
  belongs_to :tax_type_v, class_name: "TaxType"
  attr_accessible :block1_fee, :block1_limit, :block2_fee, :block2_limit, :block3_fee,
                  :block3_limit, :block4_fee, :block4_limit, :block5_fee, :block5_limit,
                  :block6_fee, :block6_limit, :block7_fee, :block7_limit, :block8_fee,
                  :block8_limit, :discount_pct_b, :discount_pct_f, :discount_pct_p, :discount_pct_v,
                  :fixed_fee, :percentage_applicable_formula, :percentage_fee, :tax_type_b_id,
                  :tax_type_f_id, :tax_type_p_id, :tax_type_v_id, :variable_fee, :tariff_type_id,
                  :billable_item_id, :caliber_id, :tariff_scheme_id, :billing_frequency_id,
                  :starting_at, :ending_at, :tariff_ids, :percentage_fixed_fee,
                  :connection_fee_a, :connection_fee_b,
                  :endowments_from, :inhabitants_from,
                  :endowments_increment, :inhabitants_increment,
                  :endowments_increment_apply_to, :inhabitants_increment_apply_to,
                  :users_from, :users_increment, :users_increment_apply_to

  has_one :active_tariff
  has_one :billable_concept, through: :billable_item

  has_many :invoice_items
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
  validates :starting_at,       :presence => true,
                                :uniqueness => { :scope => [:billable_item_id, :tariff_type_id, :caliber_id, :billing_frequency_id] }
  validates :tax_type_b,        :presence => true, :if => "!block1_fee.blank?"
  validates :tax_type_f,        :presence => true, :if => "!fixed_fee.blank?"
  validates :tax_type_p,        :presence => true, :if => "!percentage_fee.blank?"
  validates :tax_type_v,        :presence => true, :if => "!variable_fee.blank?"

  validates :block1_limit, :numericality => { :greater_than => 0}, :if => :block1_limit?
  validates :block2_limit, :numericality => { :greater_than => :block1_limit}, :if => :block2_limit?
  validates :block3_limit, :numericality => { :greater_than => :block2_limit}, :if => :block3_limit?
  validates :block4_limit, :numericality => { :greater_than => :block3_limit}, :if => :block4_limit?
  validates :block5_limit, :numericality => { :greater_than => :block4_limit}, :if => :block5_limit?
  validates :block6_limit, :numericality => { :greater_than => :block5_limit}, :if => :block6_limit?
  validates :block7_limit, :numericality => { :greater_than => :block6_limit}, :if => :block7_limit?
  validates :block8_limit, :numericality => { :greater_than => :block7_limit}, :if => :block8_limit?

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
  scope :availables_to_project_type_document_caliber, -> b,p,t,d,c { joins(:billable_item).joins(:billable_concept).order("billable_items.billable_concept_id").where("billable_items.id = ? AND billable_items.project_id = ? AND tariffs.tariff_type_id = ? AND billable_concepts.billable_document = ? AND (tariffs.caliber_id IS NULL OR tariffs.caliber_id = ? ) AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", b, p, t, d, c, Date.today)}
  scope :availables_to_project_types_items_document_caliber, -> b,p,t,d,c { joins(:billable_item).joins(:billable_concept).order("billable_items.billable_concept_id").where("billable_items.id in (?) AND billable_items.project_id = ? AND tariffs.tariff_type_id in (?) AND billable_concepts.billable_document = ? AND (tariffs.caliber_id IS NULL OR tariffs.caliber_id = ? ) AND (tariffs.ending_at IS NULL OR tariffs.ending_at >= ?)", b, p, t, d, c, Date.today)}
  scope :current, -> { where('tariffs.ending_at IS NULL OR tariffs.ending_at >= ?', Date.today) }
  scope :not_current, -> { where('tariffs.ending_at IS NOT NULL OR tariffs.ending_at < ?', Date.today) }
  scope :current_by_type, -> t { current.where(tariff_type_id: t) }
  scope :current_by_type_and_use_in_service_invoice, -> t {
    joins(:tariff_type, :billing_frequency, [billable_item: :billable_concept])
    .joins('LEFT JOIN calibers ON tariffs.caliber_id=calibers.id')
    .current_by_type(t).where("billable_concepts.billable_document = '1'")
  }
  scope :current_by_type_and_use_in_service_invoice_full, -> t {
    joins(:tariff_type, :billing_frequency, [billable_item: :billable_concept])
    .joins('LEFT JOIN calibers ON tariffs.caliber_id=calibers.id')
    .current_by_type(t).where("billable_concepts.billable_document = '1'")
    .select("tariffs.id id,
             CONCAT(tariff_types.name, ' ', billable_concepts.name, CASE ISNULL(tariffs.caliber_id) WHEN TRUE THEN '' ELSE CONCAT(' - ',calibers.caliber) END, ' (', DATE_FORMAT(tariffs.starting_at,'%d/%m/%Y'),')') tariff_label")
  }
  #mj
  scope :all_group_tariffs_without_caliber, -> w {
        joins(:tariff_type, :billing_frequency, [billable_item: :billable_concept])
        .where(w).select("tariffs.id, tariffs.billable_item_id, tariffs.tariff_type_id, tariffs.billing_frequency_id, tariffs.starting_at, tariffs.ending_at, tariffs.caliber_id,
        CONCAT(billable_concepts.name) billable_concept_label_, tariff_types.name tariff_type_label_,
        CASE (billing_frequencies.days = 0) WHEN TRUE THEN CONCAT(billing_frequencies.name, ' ',billing_frequencies.months, ' mes/es') ELSE CONCAT(billing_frequencies.name, ' ',billing_frequencies.days, ' día/s') END billing_frequency_label_")
        .group('tariffs.billable_item_id, tariffs.tariff_type_id, tariffs.billing_frequency_id, tariffs.starting_at, tariffs.ending_at')
        .order('tariffs.tariff_type_id')
  }
  scope :all_tariffs_with_caliber, -> bi,tt,bf,sa,ea {
    joins(:tariff_type, :billing_frequency, [billable_item: :billable_concept])
    .joins('LEFT JOIN calibers ON tariffs.caliber_id=calibers.id')
    .where('tariffs.billable_item_id = ? AND tariffs.tariff_type_id = ? AND tariffs.billing_frequency_id = ? AND tariffs.starting_at = ? AND (tariffs.ending_at = ? OR tariffs.ending_at IS NULL)',bi, tt, bf, sa, ea)
    .select("tariffs.id id, CASE ISNULL(tariffs.caliber_id) WHEN TRUE THEN '' ELSE calibers.caliber END caliber_")
  }

  # Callbacks
  before_destroy :check_for_dependent_records
  after_save :assing_ending_at, :reindex_tariff
  after_destroy :reindex_tariff

  def to_label
    "#{tariff_type.name} #{try(:billable_item).try(:billable_concept).try(:name)} - #{caliber.try(:caliber)} (#{I18n.l(starting_at) rescue nil})"
  end

  def full_name
    "#{try(:billable_item).try(:billable_concept).try(:name)} #{tariff_type.name} (#{I18n.l(starting_at) rescue nil} - #{I18n.l(ending_at) rescue nil})"
  end

  # THIS METHOD IS CONCEPTUALLY WRONG!!
  # DO NOT USE!!!
  def tariff_active
    if block1_fee == 0.0 && block2_fee == 0.0 && block3_fee == 0.0 && block4_fee == 0.0 && block5_fee == 0.0 && block6_fee == 0.0 && block7_fee == 0.0 && block8_fee == 0.0 && fixed_fee == 0.0 && variable_fee == 0.0 && percentage_fee == 0.0 && connection_fee_a == 0.0 && connection_fee_b == 0.0
      return false
    else
      return true
    end
  end

  # USE THIS METHOD TO CHECK IF IT'S ACTIVE
  def active?
    ending_at.blank? || ending_at < Date.today
    # ending_at.blank?
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

  def self.search_box(pr=nil,tt=nil,bc=nil,bi=nil,cc=nil,bf=nil,sa=nil,ea=nil)
    #       .where('billable_items.project_id in (?) OR tariffs.tariff_type_id = ? OR billable_items.billable_concept_id = ? OR tariffs.billable_item_id = ? OR tariffs.caliber_id = ? OR tariffs.billing_frequency_id = ? OR tariffs.starting_at >= ? OR tariffs.ending_at <= ?', pr, tt, bc, bi, cc, bf, sa, ed )
    # Builds WHERE
    w = ''
    if !pr.blank?
      w += " AND " if w != ''
      w += "billable_items.project_id IN (#{pr})"
    end
    if !tt.blank?
      w += " AND " if w != ''
      w += "tariffs.tariff_type_id = #{tt}"
    end
    if !bc.blank?
      w += " AND " if w != ''
      w += "billable_items.billable_concept_id = #{bc}"
    end
    if !bi.blank?
      w += " AND " if w != ''
      w += "tariffs.billable_item_id = #{bi}"
    end
    if !cc.blank?
      w += " AND " if w != ''
      w += "tariffs.caliber_id = #{cc}"
    end
    if !bf.blank?
      w += " AND " if w != ''
      w += "tariffs.billing_frequency_id = #{bf}"
    end
    if !sa.blank?
      w += " AND " if w != ''
      w += "tariffs.starting_at >= '#{sa.to_date}'"
    end
    if !ea.blank?
      w += " AND " if w != ''
      w += "tariffs.ending_at <= '#{ea.to_date}'"
    end
    Tariff.all_group_tariffs_without_caliber(w)
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

  searchable do
    integer :id
    integer :project_id do
      billable_item.project_id
    end
    integer :tariff_type_id
    integer :billable_item_id
    integer :caliber_id
    integer :billing_frequency_id
    integer :billable_concept_code do
      billable_item.billable_concept_id unless billable_item.blank?
    end
    time :ending_at
    time :starting_at
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
