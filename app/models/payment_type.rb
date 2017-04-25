class PaymentType < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :organization
  attr_accessible :name, :payment_method_id, :organization_id
end
