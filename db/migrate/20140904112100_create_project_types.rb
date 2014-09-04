class CreateProjectTypes < ActiveRecord::Migration
  def change
    create_table :project_types do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :project_types, :code
  end
end
