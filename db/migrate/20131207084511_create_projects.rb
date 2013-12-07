class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.date :opened_at
      t.date :closed_at
      t.references :office
      t.references :company
      t.string :ledger_account

      t.timestamps
    end
    add_index :projects, :office_id
    add_index :projects, :company_id
    add_index :projects, :name
    add_index :projects, :ledger_account
  end
end
