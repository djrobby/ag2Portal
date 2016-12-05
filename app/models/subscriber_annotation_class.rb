class SubscriberAnnotationClass < ActiveRecord::Base
  attr_accessible :code, :name, :type

  has_many :subscriber_annotations

  has_paper_trail

  validates :code,  :presence => true,
                    :length => { :minimum => 2, :maximum => 4 },
                    :uniqueness => true
  validates :name,  :presence => true
  validates :type,  :presence => true,
                    :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 2 }

  def type_label
    case type
      when 1 then I18n.t('activerecord.attributes.subscriber_annotation_class.type_1')
      when 2 then I18n.t('activerecord.attributes.subscriber_annotation_class.type_2')
      else 'N/A'
    end
  end
end
