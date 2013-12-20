class CreateWorkerItems < ActiveRecord::Migration
  def change
    create_table :worker_items do |t|
      t.references :worker
      t.references :company
      t.references :office
      t.references :professional_group
      t.references :collective_agreement
      t.references :contract_type
      t.string :contribution_account_code
      t.references :department
      t.string :position
      t.references :insurance
      t.string :nomina_id
      t.date :starting_at
      t.date :ending_at
      t.date :issue_starting_at

      t.timestamps
    end
    add_index :worker_items, :worker_id
    add_index :worker_items, :company_id
    add_index :worker_items, :office_id
    add_index :worker_items, :professional_group_id
    add_index :worker_items, :collective_agreement_id
    add_index :worker_items, :contract_type_id
    add_index :worker_items, :department_id
    add_index :worker_items, :insurance_id
    add_index :worker_items, :contribution_account_code
    add_index :worker_items, :nomina_id
  end
end
