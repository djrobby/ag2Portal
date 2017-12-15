class BillingIncidence < ActiveRecord::Base
  belongs_to :bill
  belongs_to :invoice
  belongs_to :billing_incidence_type
  # attr_accessible :title, :body
end
