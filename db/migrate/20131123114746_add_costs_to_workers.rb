class AddCostsToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :social_security_cost, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :workers, :education, :string
    add_column :workers, :sex_id, :integer
    add_column :workers, :insurance_id, :integer

    add_index :workers, :sex_id
    add_index :workers, :insurance_id
  end
end
