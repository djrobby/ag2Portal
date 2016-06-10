class BillingPeriod < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_frequency
  attr_accessible :billing_ending_date, :billing_starting_date, :charging_ending_date, :charging_starting_date, :description, :period, :prebilling_ending_date, :prebilling_starting_date, :reading_ending_date, :reading_starting_date
end
