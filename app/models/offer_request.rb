class OfferRequest < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :project
  belongs_to :approved_offer, :class_name => 'Offer'
  belongs_to :approver, :class_name => 'User'
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :approval_date, :deadline_date, :request_date, :request_no, :remarks,
                  :discount_pct, :discount, :payment_method_id, :project_id, :approved_offer_id,
                  :approver_id, :store_id, :work_order_id, :charge_account_id 

  has_many :offer_request_suppliers, dependent: :destroy
  has_many :offer_request_items, dependent: :destroy
  has_many :offers

  has_paper_trail

  validates :request_date,    :presence => true
  validates :request_no,      :presence => true
  validates :payment_method,  :presence => true

  before_destroy :check_for_dependent_records

  #
  # Records navigator
  #
  def to_first
    OfferRequest.order("id").first
  end

  def to_prev
    OfferRequest.where("id < ?", id).order("id").last
  end

  def to_next
    OfferRequest.where("id > ?", id).order("id").first
  end

  def to_last
    OfferRequest.order("id").last
  end

  private

  def check_for_dependent_records
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.offer_request.check_for_offers'))
      return false
    end
  end
end
