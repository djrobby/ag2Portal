class OfferItem < ActiveRecord::Base
  belongs_to :offer
  belongs_to :product
  belongs_to :tax_type
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessor :thing
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :price, :quantity,
                  :offer_id, :product_id, :tax_type_id, :project_id, :store_id, :work_order_id,
                  :charge_account_id, :thing

  has_paper_trail

  #validates :offer,           :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :project,         :presence => true
  validates :store,           :presence => true
  #validates :work_order,      :presence => true
  validates :charge_account,  :presence => true

  # Callbacks
  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end

  #
  # Calculated fields
  #
  def amount
    quantity * (price - discount)
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    if offer && !offer.discount_pct.blank?
      amount - (amount * (offer.discount_pct / 100))
    else
      amount
    end
  end

  def net_tax
    if offer && !offer.discount_pct.blank?
      tax - (tax * (offer.discount_pct / 100))
    else
      tax
    end
  end
end
