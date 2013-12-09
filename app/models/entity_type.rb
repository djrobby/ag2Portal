class EntityType < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_many :entities

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_entities

  private
  def check_for_entities
    if apps.count > 0
      errors.add(:base, I18n.t('activerecord.models.entity_type.check_for_entities'))
      return false
    end
  end
end
