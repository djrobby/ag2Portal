class SubscriberAnnotation < ActiveRecord::Base
  include ModelsModule

  belongs_to :subscriber
  belongs_to :subscriber_annotation_class
  attr_accessible :annotation, :subscriber_id, :subscriber_annotation_class_id,
                  :created_by, :updated_by

  validates :subscriber,                  :presence => true
  validates :subscriber_annotation_class, :presence => true

  # Scopes
  scope :by_subscriber_class, -> { order(:subscriber_id, :subscriber_annotation_class_id) }
  #
  scope :belongs_subscriber, -> s { where("subscriber_id = ?", s).by_subscriber_class }
  scope :belongs_to_class, -> c { where("subscriber_annotation_class_id = ?", c).by_subscriber_class }
  scope :belongs_to_subscriber_class, -> s, c { where("subscriber_id = ? AND subscriber_annotation_class_id = ?", s, c).by_subscriber_class }

  def annotation_class_code
    subscriber_annotation_class_id.blank? ? 'N/A' : subscriber_annotation_class.code
  end

  def annotation_class_type
    subscriber_annotation_class_id.blank? ? 'N/A' : subscriber_annotation_class.type_label
  end

  def annotation_created_at
    formatted_date(created_at) rescue ''
  end

  def annotation_created_by
    User.find(created_by).email rescue 'N/A'
  end
end
