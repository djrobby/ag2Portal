class App < ActiveRecord::Base
  belongs_to :site
  attr_accessible :description, :icon_file, :name, :path, :pict_file, :site_id,
                  :created_by, :updated_by

  has_many :guides

  has_paper_trail

  validates :description, :presence => true
  validates :icon_file,   :presence => true
  validates :name,        :presence => true
  validates :path,        :presence => true
  validates :pict_file,   :presence => true
  validates :site,        :presence => true
  
  before_destroy :check_for_guides

  def to_label
    "#{name} (#{site.name})"
  end

  private
  def check_for_guides
    if guides.count > 0
      errors.add(:base, I18n.t('activerecord.models.app.check_for_guides'))
      return false
    end
  end
end
