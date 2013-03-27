class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :ine_cpro

      t.timestamps
    end
    add_index :provinces, :ine_cpro
  end
end
