class OfferRequest < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :project
  belongs_to :approved_offer, :class_name => 'Offer'
  belongs_to :approver, :class_name => 'User'
  attr_accessible :approval_date, :deadline_date, :request_date, :request_no, :remarks,
                  :payment_method_id, :project_id, :approved_offer_id, :approver_id

  has_many :offer_request_suppliers
  has_many :offer_request_items
  has_many :offers
end
