class TariffScheme < ActiveRecord::Base
  belongs_to :project
  belongs_to :tariff_type

  attr_accessible :ending_at, :name, :starting_at, :project_id, :tariff_type_id
  attr_accessible :tariffs_attributes

  has_many :tariffs, dependent: :destroy
  has_many :invoices

  # Nested attributes
  accepts_nested_attributes_for :tariffs,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :tariffs

  validates :project,     :presence => true
  validates :tariff_type, :presence => true
  validates :name,        :presence => true
  validates :starting_at, :presence => true

  validate :ending_at_cannot_be_less_than_started_at

  # Scopes
  scope :belongs_to_projects, -> projects { where(project_id: projects) }
  scope :actives, -> {where("ending_at IS NULL OR'ending_at' < ?", Date.today)}

  searchable do
    integer :id
    text :name
    string :name
    string :project_id
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
    .order("billable_concepts.billable_document,billable_concepts.id")
    .select{|t| t.tariff_active}.group_by{|t| t.billable_item_id}
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
      .group_by{|t| t.try(:billable_item).try(:biller_id)}
    else
      []
    end
  end

  private

  def ending_at_cannot_be_less_than_started_at
    if (!ending_at.blank? and !started_at.blank?) and ending_at < started_at
      errors.add(:ending_at, :date_invalid)
    end
  end

  def end_date_is_after_start_date
    if ending_at and ending_at <= starting_at
      errors[:ending_at] << "Ha de ser mayor que la fecha de inicio"
      return false
    else
      return true
    end
  end
end
