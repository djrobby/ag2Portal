class AddNominaIdToCollectiveAgreements < ActiveRecord::Migration
  def change
    add_column :collective_agreements, :nomina_id, :string

    add_index :collective_agreements, :nomina_id
  end
end
