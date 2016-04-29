class Zone < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :created_by, :max_order_price, :max_order_total, :name, :updated_by, :organization_id
  attr_accessible :zone_notifications_attributes

  has_many :offices
  has_many :zone_notifications, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :zone_notifications,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  private

  def check_for_dependent_records
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.zone.check_for_offices'))
      return false
    end
  end
end
