class AddNominaIdToProfessionalGroups < ActiveRecord::Migration
  def change
    add_column :professional_groups, :nomina_id, :string

    add_index :professional_groups, :nomina_id
  end
end
