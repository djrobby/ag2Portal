class SubscriberAnnotationClass < ActiveRecord::Base
  attr_accessible :code, :name, :type

  has_many :subscriber_annotations

  validates :code,  :presence => true
  validates :name,  :presence => true
  validates :type,  :presence => true
end
