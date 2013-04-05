class AddCodesToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :professional_group_id, :integer
    add_column :workers, :collective_agreement_id, :integer
    add_column :workers, :degree_type_id, :integer
    add_column :workers, :contract_type_id, :integer

    add_index :workers, :professional_group_id
    add_index :workers, :collective_agreement_id
    add_index :workers, :degree_type_id
    add_index :workers, :contract_type_id
  end
end
