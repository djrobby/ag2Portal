class Store < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  attr_accessible :location, :name, :company_id, :office_id

  has_paper_trail

  validates :name,       :presence => true
  validates :company_id, :presence => true

  before_destroy :check_for_dependent_records

  has_many :stocks
  has_many :products, :through => :stocks

  private

  def check_for_dependent_records
    # Check for stocks
    if stocks.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_stocks'))
      return false
    end
  end
end
