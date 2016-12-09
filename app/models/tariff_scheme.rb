class TariffScheme < ActiveRecord::Base
  belongs_to :project
  belongs_to :tariff_type
  belongs_to :use
  attr_accessible :ending_at, :name, :starting_at, :project_id, :tariff_type_id,
                  :tariff, :tariffs_attributes, :use_id,
                  :created_by, :updated_by
  attr_accessible :tariff_scheme_items_attributes

  #has_many :tariffs, dependent: :destroy
  has_many :invoices
  has_many :tariff_scheme_items, dependent: :destroy

  # Nested attributes
  # accepts_nested_attributes_for :tariffs,
  #                               :reject_if => :all_blank,
  #                               :allow_destroy => true
  accepts_nested_attributes_for :tariff_scheme_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  # validates_associated :tariffs
  validates_associated :tariff_scheme_items

  validates :project,     :presence => true
  validates :name,        :presence => true
  validates :starting_at, :presence => true
  # validates :tariff_type, :presence => true
  # validates :use,         :presence => true

  validate :end_after_start

  before_destroy :check_for_dependent_records

  # Scopes
  scope :belongs_to_projects, -> projects { where(project_id: projects) }
  scope :actives, -> {where("ending_at IS NULL OR'ending_at' < ?", Date.today)}

  searchable do
    integer :id
    text :name
    string :name
    text :description do
      name
    end
    integer :project_id
    integer :office_id do
      project.office_id
    end
    integer :company_id do
      project.company_id
    end
    text :project do
      project.name
    end
    text :company do
      company.name
    end
    text :office do
      office.name
    end
    time :ending_at
    time :starting_at
  end

  def office
    project.office
  end

  def company
    project.company
  end

  def active?
    ending_at.blank? || ending_at < Date.today
  end

  def contain_tariffs_active
    tariffs_active = self.tariffs.joins(:billable_item => :billable_concept)
    .order("billable_concepts.billable_document,billable_concepts.id,tariffs.caliber_id")#.select{|t| t.tariff_active}
    .group_by{|t| t.billable_item_id}
  end

  def to_label
    "#{name} (#{I18n.l(starting_at)})"
  end

  def tariffs_contract(caliber_id)
    unless tariffs.blank?
      tariffs.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document).to_s == '2'}
      .select{|t| t.caliber_id.nil? || t.caliber.try(:id) == caliber_id}
      .group_by{|t| t.try(:billable_item).try(:biller_id)}
    else
      []
    end
  end

  def tariffs_supply(caliber_id)
    unless tariffs.blank?
      tariffs.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document).to_s == '1'}
      .select{|t| t.caliber_id.nil? || t.caliber.try(:id) == caliber_id}
      .sort{|a,b| a.percentage_applicable_formula && b.percentage_applicable_formula ? a.percentage_applicable_formula <=> b.percentage_applicable_formula : a.percentage_applicable_formula ? 1 : -1 }
      .group_by{|t| t.try(:billable_item).try(:biller_id)}
    else
      []
    end
  end

  private

  def ending_at_cannot_be_less_than_started_at
    if (!ending_at.blank? and !starting_at.blank?) and ending_at < starting_at
      errors.add(:ending_at, :date_invalid)
    end
  end

  def end_after_start
    if ending_at and ending_at <= starting_at
      errors.add(:ending_at, :date_invalid)
      return false
    else
      return true
    end
  end

  # Before destroy
  def check_for_dependent_records
    # Check for invoices
    if invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.tariff.check_for_invoices'))
      return false
    end
  end
end
