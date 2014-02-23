class Offer < ActiveRecord::Base
  belongs_to :offer_request
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :offer_date, :offer_no, :remarks, :discount_pct, :discount,
                  :offer_request_id, :supplier_id, :payment_method_id,
                  :project_id, :store_id, :work_order_id, :charge_account_id
  
  has_many :offer_items, dependent: :destroy
  has_many :purchase_orders
  #has_one :approver_offer_request, :class_name => 'OfferRequest', :foreign_key => 'approved_offer_id'

  has_paper_trail

  validates :offer_date,      :presence => true
  validates :offer_no,        :presence => true
  validates :supplier,        :presence => true
  validates :payment_method,  :presence => true
  validates :offer_request,   :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{id} #{offer_no} #{supplier.name}"
  end

  #
  # Records navigator
  #
  def to_first
    Offer.order("id").first
  end

  def to_prev
    Offer.where("id < ?", id).order("id").last
  end

  def to_next
    Offer.where("id > ?", id).order("id").first
  end

  def to_last
    Offer.order("id").last
  end

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.offer.check_for_purchase_orders'))
      return false
    end
  end
end
