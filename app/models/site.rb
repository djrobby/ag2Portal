class Site < ActiveRecord::Base
  attr_accessible :description, :icon_file, :name, :path, :pict_file,
                  :created_by, :updated_by

  has_many :apps
  has_many :guides

  has_paper_trail

  validates :description, :presence => true
  validates :icon_file,   :presence => true
  validates :name,        :presence => true
  validates :path,        :presence => true
  validates :pict_file,   :presence => true

  before_destroy :check_for_apps_guides

  private
  def check_for_apps_guides
    if apps.count > 0
      errors.add(:base, I18n.t('activerecord.models.site.check_for_apps'))
      return false
    end
    if guides.count > 0
      errors.add(:base, I18n.t('activerecord.models.site.check_for_guides'))
      return false
    end
  end
end
