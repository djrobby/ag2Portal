class SubscriberAnnotation < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :subscriber_annotation_class
  attr_accessible :annotation, :subscriber_id, :subscriber_annotation_class_id

  validates :subscriber,                  :presence => true
  validates :subscriber_annotation_class, :presence => true
end
