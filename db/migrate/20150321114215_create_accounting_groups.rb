class CreateAccountingGroups < ActiveRecord::Migration
  def change
    create_table :accounting_groups do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :accounting_groups, :code, unique: true
  end
end
