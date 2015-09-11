class Guide < ActiveRecord::Base
  belongs_to :site
  belongs_to :app
  attr_accessible :body, :description, :name, :site_id, :app_id, :sort_order

  has_many :subguides

  has_paper_trail

  validates :name,        :presence => true,
                          :uniqueness => true
  validates :description, :presence => true
  validates :site,        :presence => true
  validates :sort_order,  :presence => true

  before_destroy :check_for_subguides

  def to_label
    "#{sort_order} #{name}"
  end

  private
  def check_for_subguides
    if subguides.count > 0
      errors.add(:base, I18n.t('activerecord.models.app.check_for_subguides'))
      return false
    end
  end
end
