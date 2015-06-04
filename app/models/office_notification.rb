class OfficeNotification < ActiveRecord::Base
  belongs_to :office
  belongs_to :notification
  belongs_to :user
  attr_accessible :role, :office_id, :notification_id, :user_id

  has_paper_trail

  def role_label
    role_label = case action
      when 1 then I18n.t('activerecord.attributes.office_notification.role_1')
      when 2 then I18n.t('activerecord.attributes.office_notification.role_2')
      else 'N/A'
    end
  end
end
