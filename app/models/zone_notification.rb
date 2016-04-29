class ZoneNotification < ActiveRecord::Base
  belongs_to :zone
  belongs_to :notification
  belongs_to :user
  attr_accessible :role, :zone_id, :notification_id, :user_id

  has_paper_trail

  validates :notification,  :presence => true
  validates :user,          :presence => true
  validates :role,          :presence => true

  def role_label
    role_label = case role
      when 1 then I18n.t('activerecord.attributes.zone_notification.role_1')
      when 2 then I18n.t('activerecord.attributes.zone_notification.role_2')
      else 'N/A'
    end
  end
end
