class AddEBillCodeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :ebill_code, :string
    add_column :companies, :void_ebill_code, :string

    add_index :companies, :ebill_code
    add_index :companies, :void_ebill_code
  end
end
