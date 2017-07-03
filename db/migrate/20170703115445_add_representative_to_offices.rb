class AddRepresentativeToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :r_last_name, :string
    add_column :offices, :r_first_name, :string
    add_column :offices, :r_fiscal_id, :string
  end
end
