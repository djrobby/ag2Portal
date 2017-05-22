class CreateCashDeskClosings < ActiveRecord::Migration
  def change
    create_table :cash_desk_closings do |t|
      t.references :organization
      t.references :company
      t.references :office
      t.references :project
      t.timestamp :last_closing
      t.decimal :opening_balance, :precision => 13, :scale => 4, :null => false, :default => 0
      t.decimal :closing_balance, :precision => 13, :scale => 4, :null => false, :default => 0
      t.decimal :amount_collected, :precision => 13, :scale => 4, :null => false, :default => 0
      t.integer :invoices_collected

      t.timestamps
    end
    add_index :cash_desk_closings, :organization_id
    add_index :cash_desk_closings, :company_id
    add_index :cash_desk_closings, :office_id
    add_index :cash_desk_closings, :project_id
  end
end
