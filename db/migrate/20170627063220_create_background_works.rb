class CreateBackgroundWorks < ActiveRecord::Migration
  def change
    create_table :background_works do |t|
      t.integer :user_id
      t.string :work_no
      t.integer :group_no
      t.integer :total
      t.text :failure
      t.string :status
      t.string :type_work
      t.boolean :complete, default: false
      t.integer :consumption
      t.decimal :price_total, :precision => 12, :scale => 4, :default => 0.0, :null => false
      t.integer :total_confirmed
      t.date :invoice_date
      t.date :payday_limit
      t.string :first_bill
      t.string :last_bill

      t.timestamps
    end
  end
end
