class AddNominaIdToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :nomina_id, :string

    add_index :offices, :nomina_id
  end
end
