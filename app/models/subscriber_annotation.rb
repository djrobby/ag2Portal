class SubscriberAnnotation < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :subscriber_annotation
  attr_accessible :annotation

  validates :subscriber,            :presence => true
  validates :subscriber_annotation, :presence => true
end
