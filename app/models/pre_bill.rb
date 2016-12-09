class PreBill < ActiveRecord::Base
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
  belongs_to :bill
  belongs_to :reading_1, :class_name => 'Reading' #periodo anterior
  belongs_to :reading_2, :class_name => 'Reading' #año anterior

  attr_accessible :bill_date, :bill_no, :first_name, :last_name, :company, :fiscal_id,
                  :project_id, :invoice_status_id, :subscriber_id, :client_id,
                  :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :bill_id, :confirmation_date,
                  :pre_group_no, :street_name, :street_number, :building, :floor, :floor_office, :created_by, :updated_by,
                  :reading_1_id, :reading_2_id

  has_many :pre_invoices
  has_one :water_supply_contract
  has_many :client_payments

  def total_by_concept(billable_concept)
    pre_invoices.map(&:pre_invoice_items).flatten.select{|item| item.tariff.billable_item.billable_concept_id == billable_concept.to_i}.sum(&:amount)
  end

  def reading
    reading_2
  end

  def bill_type
    pre_invoices.first.invoice_type rescue nil
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
    pre_invoices.each do |i|
      if !i.total.blank?
        total += i.total
      end
    end
    total
  end

  # PreBill no
  def self.next_no
    code = ''
    # Builds code, if possible
    last_code = PreBill.order(:pre_group_no).maximum(:pre_group_no)
    if last_code.nil?
      code = 1
    else
      code = last_code + 1
    end
    code
  end

end
