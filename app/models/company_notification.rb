class CompanyNotification < ActiveRecord::Base
  belongs_to :company
  belongs_to :notification
  belongs_to :user
  attr_accessible :role, :company_id, :notification_id, :user_id

  has_paper_trail

  validates :notification,  :presence => true
  validates :user,          :presence => true
  validates :role,          :presence => true

  def role_label
    role_label = case role
      when 1 then I18n.t('activerecord.attributes.company_notification.role_1')
      when 2 then I18n.t('activerecord.attributes.company_notification.role_2')
      else 'N/A'
    end
  end
end
