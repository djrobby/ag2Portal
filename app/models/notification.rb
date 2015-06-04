class Notification < ActiveRecord::Base
  attr_accessible :action, :name, :table

  has_many :company_notifications
  has_many :office_notifications

  has_paper_trail

  validates :name,    :presence => true
  validates :action,  :presence => true
  validates :table,   :presence => true

  def to_label
    "#{name}"
  end

  def crud_label
    crud_label = case action
      when 1 then I18n.t('activerecord.attributes.notification.crud_1')
      when 2 then I18n.t('activerecord.attributes.notification.crud_2')
      when 3 then I18n.t('activerecord.attributes.notification.crud_3')
      else 'N/A'
    end
  end
end
