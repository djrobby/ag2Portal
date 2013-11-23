class CreateInsurances < ActiveRecord::Migration
  def change
    create_table :insurances do |t|
      t.string :name

      t.timestamps
    end
    add_index :insurances, :name
  end
end
