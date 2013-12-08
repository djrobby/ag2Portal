class PaymentMethod < ActiveRecord::Base
  attr_accessible :default_interest, :description, :expiration_days

  has_many :suppliers
  has_many :purchase_orders

  has_paper_trail

  validates :description, :presence => true

  def to_label
    "#{description}"
  end
end
