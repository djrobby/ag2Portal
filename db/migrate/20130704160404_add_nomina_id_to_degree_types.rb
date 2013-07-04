class AddNominaIdToDegreeTypes < ActiveRecord::Migration
  def change
    add_column :degree_types, :nomina_id, :string

    add_index :degree_types, :nomina_id
  end
end
