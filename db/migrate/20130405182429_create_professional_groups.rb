class CreateProfessionalGroups < ActiveRecord::Migration
  def change
    create_table :professional_groups do |t|
      t.string :name
      t.string :pg_code

      t.timestamps
    end
    add_index :professional_groups, :pg_code
  end
end
