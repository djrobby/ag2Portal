class PaymentMethod < ActiveRecord::Base
  attr_accessible :default_interest, :description, :expiration_days

  has_paper_trail

  validates :description, :presence => true

  has_many :suppliers
  has_many :purchase_orders

  def to_label
    "#{description}"
  end
end
