# encoding: utf-8

class SubscriberTariff < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :tariff
  attr_accessible :subscriber_id, :tariff_id, :started_at, :ending_at

  validates :subscriber,  :presence => true
  validates :tariff,      :presence => true
  validates :starting_at, :presence => true

  # Scopes
  scope :by_code, -> { order(:client_code) }
  scope :by_starting_at_and_billable_item, -> { order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  #
  scope :belongs_to_subscriber, -> s { joins(:tariff).where(subscriber_id: s).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :belongs_to_tariff, -> t { joins(:tariff).where(tariff_id: t).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables, -> { joins(:tariff).where('subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?', Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_subscriber, -> s { joins(:tariff).where("subscriber_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", s, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_tariff, -> t { joins(:tariff).where("tariff_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", t, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_subscriber_tariffs, -> s, t { joins(:tariff).where("subscriber_id = ? AND tariff_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", s, t, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_subscriber_full, -> s {
    joins(tariff: [:tariff_type, :billing_frequency, [billable_item: :billable_concept]])
    .where("subscriber_tariffs.subscriber_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", s, Date.today)
    .select("billable_concepts.name billable_concept_name, tariff_types.name tariff_type_name,
             CONCAT(billing_frequencies.name, ' - ', CASE billing_frequencies.days WHEN 0 THEN CONCAT(CAST(billing_frequencies.months AS CHAR),' mes/es') ELSE CONCAT(CAST(billing_frequencies.days AS CHAR),' día/s') END) billing_frequency_label,
             subscriber_tariffs.starting_at starting_at, subscriber_tariffs.ending_at ending_at, subscriber_tariffs.tariff_id tariff_id")
    .by_starting_at_and_billable_item
  }

  before_validation :assign_at

  def active?
    ending_at.blank?
  end

  private

  def assign_at
    self.starting_at = tariff.starting_at
    self.ending_at = tariff.ending_at
  end
end
