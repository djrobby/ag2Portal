class AddOfficeCodeToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :office_code, :string

    add_index :offices, :office_code
  end
end
