class SubscriberTariff < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :tariff
  attr_accessible :subscriber_id, :tariff_id, :started_at, :ending_at

  validates :subscriber,  :presence => true
  validates :tariff,      :presence => true
  validates :starting_at, :presence => true

  # Scopes
  scope :by_code, -> { order(:client_code) }
  #
  scope :belongs_to_subscriber, -> s { joins(:tariff).where(subscriber_id: s).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :belongs_to_tariff, -> t { joins(:tariff).where(tariff_id: t).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables, -> { joins(:tariff).where('subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?', Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_subscriber, -> s { joins(:tariff).where("subscriber_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", s, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_tariff, -> t { joins(:tariff).where("tariff_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", t, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }
  scope :availables_to_subscriber_tariffs, -> s, t { joins(:tariff).where("subscriber_id = ? AND tariff_id = ? AND (subscriber_tariffs.ending_at IS NULL OR subscriber_tariffs.ending_at > ?)", s, t, Date.today).order('subscriber_tariffs.starting_at DESC, tariffs.billable_item_id') }

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
