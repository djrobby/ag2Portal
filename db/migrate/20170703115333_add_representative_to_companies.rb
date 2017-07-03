class AddRepresentativeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :r_last_name, :string
    add_column :companies, :r_first_name, :string
    add_column :companies, :r_fiscal_id, :string
  end
end
