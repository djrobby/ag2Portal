class AddIsForeignToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :is_foreign, :boolean, null: false, default: false
    add_column :entities, :country_of_birth, :integer

    add_index :entities, :country_of_birth
  end
end
