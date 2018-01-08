class SubscriberEstimationBalance < ActiveRecord::Base
  belongs_to :subscriber
  attr_accessible :estimation_init_at, :estimation_balance, :estimation_reset_at,
                  :subscriber_id, :created_by, :updated_by

  validates :subscriber, :presence => true

  # Scopes
  scope :by_id, -> { order(:id) }
  scope :by_init_at, -> { order(:estimated_init_at) }
  scope :by_reset_at, -> { order(:estimation_reset_at) }
  #
  scope :active, -> { where("estimation_reset_at IS NULL").by_id }
  scope :by_subscriber, -> s { where(subscriber_id: s).by_id }
  scope :active_by_subscriber, -> s { where("estimation_reset_at IS NULL AND subscriber_id = ?", s).by_id }
end
