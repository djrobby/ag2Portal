class Subscriber < ActiveRecord::Base
  belongs_to :client
  belongs_to :office
  belongs_to :center
  attr_accessible :company, :first_name, :fiscal_id, :last_name, :subscriber_code
end
