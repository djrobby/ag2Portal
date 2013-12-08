class OrderStatus < ActiveRecord::Base
  attr_accessible :approval, :name, :notification

  has_many :purchase_orders

  has_paper_trail

  validates :name,  :presence => true
end
