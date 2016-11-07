class Instalment < ActiveRecord::Base
  belongs_to :instalment_plan
  belongs_to :bill
  belongs_to :invoice
  attr_accessible :amount, :instalment, :payday_limit, :surcharge,
                  :instalment_plan_id, :bill_id, :invoice_id

  has_one :client_payment

  # validates :code,  :presence => true
  # validates :name,  :presence => true
  # validates :type,  :presence => true


  searchable do
    integer :client_payment do
      client_payment.nil? ? nil : client_payment.id
    end
    text :bill_no do
      bill.bill_no
    end
    string :bill_no, :multiple => true do
      bill.bill_no
    end   # Multiple search values accepted in one search (inverse_no_search)
    integer :project_id, :multiple => true do
      bill.project_id
    end
    integer :client_id do
      bill.client_id
    end
    integer :subscriber_id do
      bill.subscriber_id
    end
    integer :entity_id do
      bill.client.entity_id
    end
    boolean :bank_account do
      bill.client.active_bank_accounts?
    end
    integer :billing_period do
      bill.reading_2.nil? ? nil : bill.reading_2.billing_period_id
    end
    integer :reading_route_id do
      bill.subscriber.nil? ? nil : bill.subscriber.reading_route_id
    end
    string :sort_no do
      bill.bill_no
    end
  end

  #
  # Calculated fields
  #
  def total
    amount + surcharge
  end

  def amount_collected
  end

  def surcharge_collected
  end

  def amount_debt
  end

  def surcharge_debt
  end

  def debt
  end
end
