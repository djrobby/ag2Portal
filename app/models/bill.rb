class Bill < ActiveRecord::Base
  belongs_to :project
  belongs_to :invoice_status
  belongs_to :subscriber
  belongs_to :client
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country

  attr_accessible :bill_date, :bill_no, :first_name, :last_name, :company, :fiscal_id,
                  :project_id, :invoice_status_id, :subscriber_id, :client_id,
                  :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id

  has_many :invoices
  has_many :client_payments
  has_one :water_supply_contract
  has_one :pre_bill

  def bill_type
    invoices.first.invoice_type rescue nil
    #reading.nil? ? "contratacion" : "suministro"
  end

  def full_no
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    if bill_no == "$err"
      "000000000000-000-00000"
    else
      #bill_no.blank? ? "" : bill_no[0..11] + '-' + bill_no[12..15] + '-' + bill_no[16..21]
    end
  end

  def total
    total = 0
    invoices.each do |i|
      if !i.total.blank?
        total += i.total
      end
    end
    total
  end
end
