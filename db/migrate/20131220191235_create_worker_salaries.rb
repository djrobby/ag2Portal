class CreateWorkerSalaries < ActiveRecord::Migration
  def change
    create_table :worker_salaries do |t|
      t.references :worker_item
      t.integer :year, :limit => 2
      t.decimal :gross_salary, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :variable_salary, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :social_security_cost, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :day_pct, :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '100'
      t.boolean :active

      t.timestamps
    end
    add_index :worker_salaries, :worker_item_id
    add_index :worker_salaries, :year
  end
end
