class CreateFormalityTypes < ActiveRecord::Migration
  def change
    create_table :formality_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :formality_types, :name
  end
end
