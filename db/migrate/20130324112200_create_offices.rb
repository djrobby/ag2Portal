class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :name
      t.references :company

      t.timestamps
    end
    add_index :offices, :company_id
  end
end
