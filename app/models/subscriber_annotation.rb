class SubscriberAnnotation < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :subscriber_annotation_class
  attr_accessible :annotation, :subscriber_id, :subscriber_annotation_class_id

  validates :subscriber,                  :presence => true
  validates :subscriber_annotation_class, :presence => true

  # Scopes
  scope :by_subscriber_class, -> { order(:subscriber_id, :subscriber_annotation_class_id) }
  #
  scope :belongs_subscriber, -> s { where("subscriber_id = ?", s).by_subscriber_class }
  scope :belongs_to_class, -> c { where("subscriber_annotation_class_id = ?", c).by_subscriber_class }
  scope :belongs_to_subscriber_class, -> s, c { where("subscriber_id = ? AND subscriber_annotation_class_id = ?", s, c).by_subscriber_class }
end
