class CreateBankAccountClasses < ActiveRecord::Migration
  def change
    create_table :bank_account_classes do |t|
      t.string :name

      t.timestamps
    end
    add_index :bank_account_classes, :name
  end
end
