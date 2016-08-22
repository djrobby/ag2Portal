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


  def contain_tariffs_active



    tariffs_active = self.tariffs.select{|t| t.tariff_active}.group_by{|t| t.billable_item_id}

    #tariffs = self.tariffs.group_by{|t| t.billable_item_id}
#
    #tariffs_active = []
#
    #tariffs.each do |tariffs|
      #contain_tariff_active = false
      #tariffs[1].each do |tariff|
        #if tariff.tariff_active
          #contain_tariff_active = true
        #end
      #end
#
      #if contain_tariff_active
        #tariffs_active.push(tariffs)
      #end
#
    #end

    return tariffs_active

  end

  def to_label
    "#{name} (#{I18n.l(starting_at)})"
  end

  def tariffs_contract(caliber_id)
    unless tariffs.blank?
      tariffs.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 2}
      .select{|t| t.caliber.try(:id) == caliber_id}
      .group_by{|t| t.try(:billable_item).try(:biller_id)}
    else
      []
    end
  end

  def tariffs_supply(caliber_id)
    unless tariffs.blank?
      tariffs.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 1}
      .select{|t| t.caliber.try(:id) == caliber_id}
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
