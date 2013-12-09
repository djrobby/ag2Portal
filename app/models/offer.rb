class Offer < ActiveRecord::Base
  belongs_to :offer_request
  belongs_to :supplier
  belongs_to :payment_method
  attr_accessible :offer_date, :offer_no, :remarks,
                  :offer_request_id, :supplier_id, :payment_method_id
  
  has_many :offer_items
  #has_one :approver_offer_request, :class_name => 'OfferRequest', :foreign_key => 'approved_offer_id'
end
