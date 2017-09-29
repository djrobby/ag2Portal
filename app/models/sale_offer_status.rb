class SaleOfferStatus < ActiveRecord::Base
  # CONSTANTS
  PENDING = 1
  APPROVED = 2
  DENIED = 3
  CANCELLED = 4

  attr_accessible :approval, :name, :notification

  has_many :sale_offers

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for sell offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.sale_offer.check_for_sale_offers'))
      return false
    end
  end
end
