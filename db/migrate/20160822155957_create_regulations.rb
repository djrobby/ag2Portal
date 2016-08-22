class CreateRegulations < ActiveRecord::Migration
  def change
    create_table :regulations do |t|
      t.references :project
      t.references :regulation_type
      t.string :description
      t.date :starting_at
      t.date :ending_at

      t.timestamps
    end
    add_index :regulations, :project_id
    add_index :regulations, :regulation_type_id
  end
end
