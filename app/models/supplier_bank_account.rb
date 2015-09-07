class SupplierBankAccount < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :bank_account_class
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office
  attr_accessible :account_no, :ccc_dc, :ending_at, :holder_fiscal_id, :holder_name, :iban_dc, :starting_at
end
