class AddCommercialToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :commercial_bill_code, :string

    add_index :companies, :commercial_bill_code
  end
end
