class Api::V1::BillingPeriodsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :billing_ending_date, :billing_starting_date,
                  :period, :description, :text

  # has_one :billing_frequency

  def text
    # "#{period} (#{billing_frequency.try(:name)})"
    "#{period}"
  end
end
