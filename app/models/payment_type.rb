class PaymentType < ActiveRecord::Base
  belongs_to :payment_method # Payment method for charges
  belongs_to :organization
  belongs_to :return_payment_method, :class_name => 'PaymentMethod' # Payment method for returns
  attr_accessible :name, :payment_method_id, :organization_id, :return_payment_method_id
end
