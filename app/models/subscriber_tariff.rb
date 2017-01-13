class SubscriberTariff < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :tariff
  attr_accessible :subscriber_id, :tariff_id, :started_at, :ending_at

  validates :subscriber,  :presence => true
  validates :tariff,      :presence => true
  validates :starting_at, :presence => true

  # Scopes
  scope :belongs_to_subscriber, -> s { where(subscriber_id: s) }
  scope :belongs_to_tariff, -> t { where(tariff_id: t) }
  scope :availables, -> { where('ending_at IS NULL OR ending_at > ?', Date.today) }
  scope :availables_to_subscriber, -> s { where("subscriber_id = ? AND (tariffs.ending_at IS NULL OR tariffs.ending_at > ?)", s, Date.today)}
  scope :availables_to_tariff, -> t { where("tariff_id = ? AND (tariffs.ending_at IS NULL OR tariffs.ending_at > ?)", t, Date.today)}
  scope :availables_to_subscriber_tariff, -> s, t { where("subscriber_id = ? AND tariff_id = ? AND (tariffs.ending_at IS NULL OR tariffs.ending_at > ?)", s, t, Date.today)}

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
